import 'package:flutter/material.dart';
import 'package:mobileproject/account/Change/change_email.dart';
import 'package:mobileproject/account/Change/change_password.dart';
import 'package:mobileproject/account/Change/edit_profile.dart';
import 'package:mobileproject/account/Change/delete_account.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AccountPage(),
    );
  }
}
class AccountPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text("계정 관리"),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: const Text('이메일 변경'),
              trailing: const Icon(Icons.arrow_forward_ios),
              tileColor: Colors.grey[100],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeEmailPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('비밀번호 변경'),
              trailing: Icon(Icons.arrow_forward_ios),
              tileColor: Colors.grey[100],
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('계정 삭제',style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              tileColor: Colors.grey[100],
              onTap: () {
                // 계정 삭제 기능 추가
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: '내역'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '그래프'),
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