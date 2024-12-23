import 'package:budgetbook/signup.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'findPassword.dart';
import 'notification_settings.dart';
import 'signup.dart';
import 'findID.dart';
import 'loginPage.dart';
import 'chartDay.dart';
import 'chartWeek.dart';
import 'chartMonth.dart';
import 'chartToday.dart';
import 'bottomNavigationBar.dart';
import 'RoomSelectionPage.dart';
import 'make_share.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'firebase_messaging_service.dart';

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
        '/signUp' : (context) => SignUpPage(),
        '/chartDay': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ChartArguments;
          return ChartDayPage(
            selectedDate: args.selectedDate,
            elements: args.elements,
          );
        },
        '/chartWeek': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ChartArguments;
          return ChartWeekPage(
            selectedDate: args.selectedDate,
            elements: args.elements,
          );
        },
        '/chartMonth': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ChartArguments;
          return ChartMonthPage(
            selectedDate: args.selectedDate,
            elements: args.elements,
          );
        },
        '/chartToday' : (context) => ChartTodayPage(elements: '',),
        '/navigation': (context) {
          final elements = ModalRoute.of(context)?.settings.arguments as String? ?? 'element';
          return CustomNavigationBar(elements: elements);
        },
        '/RoomSelect' : (context) => RoomSelectionPage(),
        '/MakeRoom' : (context) => MakingSharePage(),
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  await FirebaseMessagingService.initialize();
  runApp(MyApp());
}

