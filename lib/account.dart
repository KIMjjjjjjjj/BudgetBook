import 'package:flutter/material.dart';
import 'change_email.dart';
import 'change_password.dart';
import 'delete_account.dart';

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
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
