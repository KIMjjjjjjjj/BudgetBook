import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsPage extends StatefulWidget {
  @override
  NotificationSettingsPageState createState() => NotificationSettingsPageState();
}

class NotificationSettingsPageState extends State<NotificationSettingsPage> {
  List<TextEditingController> textControllers = [];
  List<Map<String, Object>> subscriptions = [];
  String subscriptionText = '';
  int subscriptionDay = 1;
  bool spendingWarning = true;
  bool regularSpending = true;
  bool roomInvitation = true;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initState() {
    super.initState();
    initializeLocalNotifications();
    createNotificationChannel();
    loadSettings();
    requestPermission();
    setupFCM();
    scheduleRegularNotification();
  }

  Future<void> saveToFirestore(String data, int month, int day, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('alarm').add({
        'data': data,
        'month': month,
        'day': day,
        'uid': uid,
      });
    } catch (e) {
      print('에러');
    }
  }

  Future<void> deleteFromFirestore(String uid, String data, int day) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('alarm')
          .where('uid', isEqualTo: uid)
          .where('data', isEqualTo: data)
          .where('day', isEqualTo: day)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('에러');
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      spendingWarning = prefs.getBool('spendingWarning') ?? true;
      regularSpending = prefs.getBool('regularSpending') ?? true;
      roomInvitation = prefs.getBool('roomInvitation') ?? true;

      final savedSubscriptions = prefs.getStringList('subscriptions');
      if (savedSubscriptions == null || savedSubscriptions.isEmpty) {
        subscriptions = [{'text': '', 'day': 1}];
        textControllers = [TextEditingController()];
      } else {
        subscriptions = savedSubscriptions!.map((subscriptionData) {
          var parts = subscriptionData.split(':');
          return {
            'text': parts[0],
            'day': int.parse(parts[1]),
          };
        }).toList() ?? [];
        if (subscriptions.isEmpty) {
          subscriptions.add({'text': '', 'day': 1});
        }
        textControllers = subscriptions
            .map((subscription) =>
            TextEditingController(text: subscription['text'] as String))
            .toList();
      }

    });
  }
  void saveSettings() async {
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    await prefs.setBool('spendingWarning', spendingWarning);
    await prefs.setBool('regularSpending', regularSpending);
    await prefs.setBool('roomInvitation', roomInvitation);

    List<String> subscriptionsToSave = subscriptions.map((sub) {
      String text = sub['text'] as String;
      int day = sub['day'] as int;
      return '$text:$day';
    }).toList();
    await prefs.setStringList('subscriptions', subscriptionsToSave);
  }

  //초기 세팅
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }
  void setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel_id',
      'Default Channel',
      description: 'This channel is used for regular notifications',
      importance: Importance.max,
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showNotification({String? title, String? body}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'This channel is used for foreground notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    flutterLocalNotificationsPlugin.show(
      0,
      title ?? '알림',
      body ?? '내용 없음',
      notificationDetails,
    );
  }

  Future<void> scheduleRegularNotification() async {
    if (regularSpending){
      final now = tz.TZDateTime.now(tz.local);
      for (var subscription in subscriptions){
        int day = subscription['day'] as int;
        String text = subscription['text'] as String;

        tz.TZDateTime notificationTime = tz.TZDateTime(tz.local, now.year, now.month, day, 05, 25);
        if (notificationTime.isBefore(now)) {
          notificationTime = tz.TZDateTime(tz.local, now.year, now.month + 1, day, 05, 25);
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          subscription.hashCode,
          '정기 지출 알림',
          '$text에 대한 정기 지출이 예정되었습니다.',
          notificationTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel_id',
              'Default Channel',
              channelDescription: 'This channel is used for foreground notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
        _sendNotification(FirebaseAuth.instance.currentUser!.uid, text);
      }
    }
  }

  Future<void> _sendNotification(String userId, String spendingText) async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      String? fcmToken = userSnapshot.data()?['fcmToken'];

      if (fcmToken != null) {
        final callable = FirebaseFunctions.instance.httpsCallable(
            'sendRegularSpendingNotification');
        await callable.call(
            {'fcmToken': fcmToken, 'spendingText': spendingText});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            // 지출 경고 알림
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('지출 경고 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: spendingWarning,
                  onChanged: (val) {
                    setState(() => spendingWarning = val);
                    saveSettings();
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('정기 지출 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: regularSpending,
                  onChanged: (val) {
                    setState(() => regularSpending = val);
                    saveSettings();
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            SizedBox(
                height: 200,
                child: ListView.builder(
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = subscriptions[index];
                      return Row(
                        children: [
                          IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Icon(Icons.add, color: Colors.blue),
                              ),
                              onPressed: () {
                                setState(() {
                                  subscriptions.add({'text': '', 'day': 1});
                                  textControllers.add(TextEditingController());
                                });
                              }
                          ),
                          Expanded(
                            child: TextField(
                              controller: textControllers[index],
                              decoration: InputDecoration(
                                hintText: '예: NETFLIX',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  subscriptions[index]['text'] = value;
                                });
                                saveSettings();
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Text('매월', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 10),
                          DropdownButton<int>(
                            value: subscription['day'] as int,
                            items: List.generate(31, (index) => index + 1)
                                .map((day) => DropdownMenuItem<int>(
                              value: day,
                              child: Text(day.toString()),
                            ))
                                .toList(),
                            onChanged: (day) async {
                              setState(() {
                                subscription['day'] = day!;
                              });
                              saveSettings(); // 로컬 저장

                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                await saveToFirestore(
                                  subscription['text'] as String, DateTime.now().month, day!, uid,
                                );
                              }
                            },
                          ),
                          Text('일', style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () async {
                              setState(() {
                                flutterLocalNotificationsPlugin.cancel(subscriptions[index]['text'].hashCode);
                                subscriptions.removeAt(index);
                                textControllers.removeAt(index);
                              });
                              saveSettings(); // 로컬 데이터 삭제
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                await deleteFromFirestore(uid, subscription['text'] as String, subscription['day'] as int);
                              }
                            },
                          ),
                        ],
                      );
                    })
            ),
            Divider(),
            // 방 초대 알림
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('방 초대 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Switch(
                      value: roomInvitation,
                      onChanged: (val) {
                        setState(() => roomInvitation = val);
                        saveSettings();
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                Text('공유 가계부 초대 알림이 옵니다', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}