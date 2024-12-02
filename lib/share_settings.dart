import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



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
        '방 이름': roomName, 'id': FieldValue.arrayUnion([LoginUserRegisterId, ...items]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 이름이  수정되었습니다.')),
      );
    }

    setState(() {
      items.clear();
      _roomNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(
          '공유 설정',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
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
                      style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      foregroundColor: Colors.indigoAccent[700],
                      backgroundColor: Colors.indigoAccent[100],
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
              leading: Icon(Icons.chat_bubble, color: Colors.indigoAccent),
              title: Text(
                '카카오톡으로 친구 초대',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.indigoAccent),
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
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(150, 50),
                ),
                onPressed: () {
                  SaveRooms();
                },
                child: Text(
                  '수정 하기',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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
                Navigator.pop(context);
                if (userId.isNotEmpty) {
                  bool isAdded = invitefriendalarm(userId) as bool;
                  if (isAdded) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('친구 아이디가 추가되었습니다.')),
                    );
                  }
                }
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }



  Future<void> invitefriendalarm(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('사용자가 인증되지 않았습니다.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('register')
          .where('id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isEmpty) {
        print('친구 아이디를 찾을 수 없습니다.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 아이디를 찾을 수 없습니다.')),
        );
        return;
      }

      var friendData = userSnapshot.docs.first.data();
      String? fcmToken = friendData['fcmToken'] as String?;
      String? friendId = friendData['id'] as String?;

      if (fcmToken == null || friendId == null) {
        print('친구의 FCM 토큰 또는 ID가 없습니다.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('푸시 알림을 보낼 수 없습니다.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('invite').add({
          'inviterId': currentUser.uid,
          'invitedId': friendId,
          'fcmToken': fcmToken,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('친구 ID와 FCM 토큰이 invite 컬렉션에 저장되었습니다.');

        if (userSnapshot.docs.isNotEmpty) {
          setState(() {
            items.add(userId);
          });
        }
      } catch (error) {
        print('Firestore 저장 실패: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대 데이터를 저장하는 중 오류가 발생했습니다.')),
        );
        return;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
          'sendInviteNotification');
      try {
        final response = await callable.call();
        if (response.data == null || !response.data['success']) {
          throw Exception('서버에서 알림 전송이 실패했습니다.');
        }

        print('푸시 알림 전송 성공! Response: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('푸시 알림 전송 성공!')),
        );
      } catch (error) {
        print('Callable error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 전송에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('친구 추가 또는 알림 전송 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 추가 또는 알림 전송에 실패했습니다.')),
      );
    }
  }
}
