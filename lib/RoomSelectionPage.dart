import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RoomSelectionPage extends StatefulWidget {
  @override
  RoomSelectionPageState createState() => RoomSelectionPageState();
}

class RoomSelectionPageState extends State<RoomSelectionPage> {
  List<String> sharedRooms = [];
  String elements = "";

  StreamSubscription? _subscription;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    getTocken();
    initializeLocalNotifications();
    AlarmCheck();

    _subscription = FirebaseFirestore.instance
        .collection('share')
        .snapshots()
        .listen((snapshot) {
      _checkSharedRoom();
    });
  }

  void getTocken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final user = FirebaseAuth.instance.currentUser;
    print('FCM Token: $fcmToken');
    await FirebaseFirestore.instance
        .collection('register')
        .doc(user?.uid)
        .set({'fcmToken': fcmToken}, SetOptions(merge: true));
  }

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({String? title, String? body}) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: '정기 지출 알림 채널',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? ' ',
      body ?? ' ',
      notificationDetails,
    );
  }

  void AlarmCheck() {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("로그인된 사용자가 없습니다.");
      return;
    }

    FirebaseFirestore.instance.collection('alarm').snapshots().listen((snapshot) {
      final now = DateTime.now();
      final today = now.day;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final alarmUid = data['uid'];
        final alarmDay = data['day'];

        if (alarmUid == userUid && alarmDay == today) {
          showNotification(
            title: '정기 지출 알림',
            body: '금일 ${data['data']}에 대한 정기 지출이 예정되어 있습니다.',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _checkSharedRoom() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("로그인된 사용자가 없습니다.");
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('register')
        .doc(userUid)
        .get();

    final data = userDoc.data();
    final ID = data?['id'];
    if (ID == null) {
      print("ID가 없습니다.");
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('share')
        .where('id', arrayContains: ID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        sharedRooms = querySnapshot.docs
            .map((doc) => doc['방 이름']?.toString() ?? ' ')
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "가계부를 선택하세요",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildRoomBox(
                  icon: Icons.person,
                  label: '개인방',
                  onPressed: () {
                    final userUid = FirebaseAuth.instance.currentUser?.uid;
                    if (userUid != null) {
                      elements = userUid;
                      Navigator.pushNamed(context, '/navigation', arguments: elements);
                    }
                  },
                ),
                SizedBox(width: 20),
                if (sharedRooms.isNotEmpty)
                  ...sharedRooms.map((roomName) => Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: buildRoomBox(
                      icon: Icons.emoji_emotions,
                      label: roomName,
                      onPressed: () {
                        elements = roomName;
                        Navigator.pushNamed(context, '/navigation', arguments: elements);
                        print('공유방: $roomName');
                      },
                    ),
                  )).toList(),
              ],
            ),
            SizedBox(height: 30),
            buildRoomBox(
              icon: Icons.add,
              label: '방 추가',
              onPressed: () {
                Navigator.pushNamed(context, '/MakeRoom');
                print('방 추가');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomBox({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        Material(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          elevation: 4,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 70,
                color: Colors.indigoAccent,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.indigoAccent,
          ),
        ),
      ],
    );
  }
}
