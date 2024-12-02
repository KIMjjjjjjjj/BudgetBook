import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'loginPage.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  DeleteAccountPageState createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String? errorMessage1;
  String? errorMessage2;

  Future<void> deleteAccount(BuildContext context) async {
    String currentPassword = currentPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user?.reauthenticateWithCredential(credential);
      setState(() {
        errorMessage2 = null;
      });

      if (currentPassword == confirmPassword) {
        await FirebaseFirestore.instance
            .collection('register')
            .doc(user!.uid)
            .delete();


        await user?.delete();
        setState(() {
          errorMessage1 = null;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정이 삭제되었습니다.')),
        );

      } else {
        setState((){
          errorMessage1 = '비밀번호가 일치하지 않습니다.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() {
          errorMessage2 = '현재 비밀번호가 일치하지 않습니다.';
        });
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
          '계정 삭제',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '현재 비밀번호',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: '비밀번호 입력',
                errorText: errorMessage2,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 1.2),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: '비밀번호 확인 입력',
                //오류메시지
                errorText: errorMessage1,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 1.2),
                ),
              ),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(150, 50),
              ),
              onPressed: () {
                deleteAccount(context);
              },
              child: Text(
                '계정 삭제',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}