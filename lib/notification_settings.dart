import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  NotificationSettingsPageState createState() => NotificationSettingsPageState();
}

class NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool spendingWarning = true;
  bool regularSpending = true;
  bool roomInvitation = true;
  int selectedDay = 17;

  List<Map<String, dynamic>> subscriptions = [{'text': '', 'day': 1}];
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initState() {
    super.initState();
    loadSettings();
    getTocken();
    requestPermission();
    setupFCM();
  }

  Future<void> saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      spendingWarning = prefs.getBool('spendingWarning') ?? true;
      regularSpending = prefs.getBool('regularSpending') ?? true;
      roomInvitation = prefs.getBool('roomInvitation') ?? true;
    });
  }

  void getTocken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');
  }
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
        // showLocalNotification(message.notification!);
      }
    });
  }

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void showNotification({String? title, String? body}) {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'fdefault_channel_id',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
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
                    saveSettings('spendingWarning', val);
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            Divider(),
            // 정기 지출 알림
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('정기 지출 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: regularSpending,
                  onChanged: (val) {
                    setState(() => regularSpending = val);
                    saveSettings('regularSpending', val);
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
                          });
                        }
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '예: NETFLIX',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                          ),
                          onChanged: (value) {
                            setState(() {
                              subscription['text'] = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Text('매월', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      DropdownButton<int>(
                        value: subscription['day'],
                        items: List.generate(31, (index) => index + 1)
                            .map((day) => DropdownMenuItem<int>(
                              value: day,
                              child: Text(day.toString()),
                            ))
                            .toList(),
                        onChanged: (day) {
                          setState(() {
                             subscriptions[index]['day'] = day!;
                          });
                        },
                      ),
                      Text('일', style: TextStyle(fontSize: 16)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            subscriptions.removeAt(index);
                          });
                        }
                      ),
                    ],
                  );
              })
            ),
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
                        saveSettings('roomInvitation', val);
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

