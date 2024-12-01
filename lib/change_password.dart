import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginPage.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? errorMessage1;
  String? errorMessage2;

  Future<void> _changePassword() async {
    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        errorMessage2 = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    setState(() {
      errorMessage2 = null;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('사용자를 찾을 수 없습니다.');

      String email = user.email!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(_newPasswordController.text.trim());

      setState(() {
        errorMessage1 = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '현재 비밀번호가 틀렸습니다.';
          setState(() {
            errorMessage1 = errorMessage;
          });
          break;
        case 'weak-password':
          errorMessage = '비밀번호는 6자 이상이어야 합니다.';
          setState(() {
            errorMessage1 = errorMessage;
          });
          break;
        default:
          errorMessage = '비밀번호 변경에 실패했습니다: ${e.message}';
          setState(() {
            errorMessage1 = errorMessage;
          });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
      );
    }
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
        title: Text("비밀번호 변경", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigoAccent,
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
                obscureText: true,
              ),
            ),
            SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16),
                Text("새 비밀번호", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 390,
                  child: TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      hintText: "새 비밀번호",
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 390,
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: "새 비밀번호 확인",
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
                    obscureText: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text('혹시 타인에게 계정을 양도하려고 하시나요?', style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            Text('타인에 의한 계정 사용이 의심되시나요?', style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 100),

            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(150, 50),
              ),
              child: Text("비밀번호 변경", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
