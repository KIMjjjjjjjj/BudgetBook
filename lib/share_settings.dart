import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_settings.dart';


class SharingSettingsPage extends StatefulWidget {
  final String elements;

  const SharingSettingsPage({required this.elements});

  @override
  _SharingSettingsPageState createState() => _SharingSettingsPageState();
}

class _SharingSettingsPageState extends State<SharingSettingsPage> {
  List<String> items = [];
  TextEditingController _roomNameController = TextEditingController();
  TextEditingController _friendIdController = TextEditingController();

  String? LoginUserId;
  String? LoginUserRegisterId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {

      final User? user = FirebaseAuth.instance.currentUser;
      print('widget.elements: ${widget.elements}');

      if (user != null) {
        LoginUserId = user.uid;

        var snapshot = await FirebaseFirestore.instance
            .collection('register')
            .doc(LoginUserId)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data();
          if (data != null && data.containsKey('id')) {
            setState(() {
              LoginUserRegisterId = data['id'];
            });
          }
        }
      }
    }

  void SaveRooms() async {
    if (LoginUserRegisterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }


      String roomName = _roomNameController.text.trim();
      if (roomName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 이름을 입력해주세요.')),
        );
        return;
      }

      var shareCollection = FirebaseFirestore.instance.collection('share');
      var querySnapshot = await shareCollection
          .where('방 이름', isEqualTo: widget.elements)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;

        await shareCollection.doc(doc.id).update({
          '방 이름': roomName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 이름이  수정되었습니다.')),
        );
      }

      setState(() {
        _roomNameController.clear();
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          '공유 설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Row(
              children: [
                SizedBox(width: 15.0),
                Text(
                  '방 이름 설정',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10.0),
                SizedBox(
                  height: 25.0,
                  width: 40.0,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      '수정',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      foregroundColor: Colors.blue[700],
                      backgroundColor: Colors.blue[100],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: TextField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '방 이름을 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Divider(),
            ListTile(
              leading: Icon(Icons.chat_bubble, color: Colors.black),
              title: Text(
                '카카오톡으로 친구 초대',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.black),
              title: Text(
                '아이디로 친구 추가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _showInviteDialog(context);
              },
            ),
            Divider(),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        tileColor: Colors.white,
                        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                        title: Text(items[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              items.removeAt(index);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 7),
                    ],
                  );
                },
              ),
            ),
            Divider(),
            Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                minimumSize: Size(150, 50),
              ),
              onPressed: () {
                SaveRooms();
              },
              child: Text(
                '수정 하기',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('아이디로 친구 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _friendIdController,
                decoration: InputDecoration(
                  labelText: '친구 아이디 입력',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String userId = _friendIdController.text.trim();
                if (userId.isNotEmpty) {
                  bool isAdded = _addFriendById(userId) as bool;

                  final prefs = await SharedPreferences.getInstance();
                  final roomInvitation = prefs.getBool('roomInvitation') ?? true;
                  if (roomInvitation && isAdded) {
                    NotificationSettingsPageState?.showNotification(
                      title: '방 초대 알림',
                      body: '${userId}님이 가계부 공유방에 초대되셨습니다.',
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _addFriendById(String userId) async {

      var userSnapshot = await FirebaseFirestore.instance
          .collection('register')
          .where('id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          items.add(userId);
        });
        return true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 아이디가 추가되었습니다.')),
        );
      }else {
        return false;
      }
    }
}
