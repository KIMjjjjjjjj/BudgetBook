import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomSelectionPage extends StatefulWidget {
  @override
  RoomSelectionPageState createState() => RoomSelectionPageState();
}

class RoomSelectionPageState extends State<RoomSelectionPage> {
  List<String> sharedRooms = [];
  String elements = "";

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = FirebaseFirestore.instance
        .collection('share')
        .snapshots()
        .listen((snapshot) {
      _checkSharedRoom();
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
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "가계부를 선택하세요",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
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
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 70,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
