import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'loginPage.dart';
import 'account.dart';
import 'notification_settings.dart';
import 'share_settings.dart';

class SettingPage extends StatefulWidget {
  final String elements;
  const SettingPage({required this.elements});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? profileImage;
  String? profileImageUrl;
  final TextEditingController currentNicknameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();

    Timer.periodic(Duration(seconds: 1), (timer) async {
      await loadUserData();
    });
  }
  Future<void> loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc['profileImageUrl'];
          currentNicknameController.text = userDoc['nickname'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 75,
                  backgroundImage: NetworkImage(profileImageUrl!),
                )
                    : Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Colors.grey,
                ),
                SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentNicknameController.text,
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(user?.email ?? ''),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );

                        if (result != null && result['updateprofile'] == true) {
                          setState(() {
                            profileImageUrl = result['profileImageUrl'];
                          });
                        }
                      },
                      child: Text(
                        '프로필 편집',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Card(
                  child: ListTile(
                    title: const Text('계정 관리'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    tileColor: Colors.grey[100],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage()),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('알림 설정'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    tileColor: Colors.grey[100],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('공유 설정'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    tileColor: Colors.grey[100],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SharingSettingsPage(elements:widget.elements,)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 260),
                  child: Card(
                    child: ListTile(
                      title: Text('로그아웃'),
                      tileColor: Colors.grey[100],
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 180,
                  child: Card(
                    color: Colors.grey[100],
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text('버전 정보   현재 버전 1.0 (최신 버전)'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
