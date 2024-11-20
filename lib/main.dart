import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'findPassword.dart';
import 'findID.dart';
import 'loginPage.dart';
import 'chartDay.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/' : (context) => LoginPage(),
          '/findID' : (context) => FindIDPage(),
          '/findPassword' : (context) => FindPasswordPage(),
          '/chartDay' : (context) => ChartDayPage(),
        },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
