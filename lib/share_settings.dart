import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SharingSettingsPage(),
    );
  }
}


class SharingSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  height: 25.0, width: 40.0,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      '수정',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold), // Smaller font size
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
              width: 300.0, height: 50.0,
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter',
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
              onTap: () {},
            ),
            Divider(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '내역'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '그래프'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: '예산 관리'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}