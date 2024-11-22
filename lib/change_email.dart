import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  String? errorMessage1;
  String? errorMessage2;

  String? _generatedCode;
  bool _isCodeVerified = false;

  String generateRandomCode() {
    final random = Random();
    int randomNumber = 10000 + random.nextInt(90000);
    return randomNumber.toString();
  }

  Future<void> sendVerificationCode(String toEmail) async {
    String randomCode = generateRandomCode();
    setState(() {
      _generatedCode = randomCode;
      _isCodeVerified = false;
    });

    String username = 'yun7171717@gmail.com';
    String password = 'hpwr frpl dsdx uqda';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, '가계부')
      ..recipients.add(toEmail)
      ..subject = '이메일 인증 코드'
      ..text = '당신의 인증 코드는: $randomCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 코드가 이메일로 전송되었습니다.'))
      );
    } catch (e) {
      print('메시지 전송 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 전송에 실패했습니다.'))
      );
    }
  }

  void verifyCode() {
    if (_verificationCodeController.text == _generatedCode) {
      setState(() {
        _isCodeVerified = true;
        errorMessage2 = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증이 완료되었습니다.'))
      );
    } else {
      setState(() {
        errorMessage2 = '인증 코드가 일치하지 않습니다.';
      });
    }
  }

  Future<void> changeEmail() async {
    if (_isCodeVerified) {
      try {
        User? user = _auth.currentUser;
        if (user == null) throw Exception('사용자를 찾을 수 없습니다.');

        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _currentPasswordController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);

        await user.updateEmail(_newEmailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일이 성공적으로 변경되었습니다.'))
        );
        await FirebaseAuth.instance.signOut();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
            }  catch (error) {
        setState(() {
          errorMessage1 = '현재 비밀번호가 올바르지 않습니다.';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증을 먼저 완료해주세요.'))
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text("이메일 변경", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[800],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16),
                Text("현재 비밀번호", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 5),
            Container(
              width: 390,
              child: TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  hintText: "현재 비밀번호",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[300],
                  errorText: errorMessage1,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 1.2),
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                enabled: true,
              ),
            ),
            SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16),
                Text("새 이메일", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 270,
                  child: TextField(
                    controller: _newEmailController,
                    decoration: InputDecoration(
                      hintText: "새 이메일",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    sendVerificationCode(_newEmailController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black38,
                  ),
                  child: Text("인증 요청", style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 270,
                  child: TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      hintText: "인증 코드",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[300],
                      errorText: errorMessage2,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 1.2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 1.2),
                      ),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                  child: Text("인증 확인", style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: changeEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                minimumSize: Size(150, 50),
              ),
              child: Text("이메일 변경", style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
