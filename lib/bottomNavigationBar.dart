import 'chartToday.dart';
import 'HistoryPage.dart';
import 'SettingPage.dart';
import 'budget_setting.dart';
import 'chartTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide NavigationBar;


class CustomNavigationBar extends StatefulWidget {
  final String elements;

  const CustomNavigationBar({super.key, required this.elements});

  @override
  State<CustomNavigationBar> createState() => NavigationBarState();
}

class NavigationBarState extends State<CustomNavigationBar> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
  final List<Widget> _pages = [
      HistoryPage(elements: widget.elements),
      TabBarSet(elements: widget.elements),
      BudgetSetting(elements: widget.elements),
      SettingPage(elements: widget.elements),
    ];

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFB1C3D1),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '내역'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '그래프'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: '예산 관리'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: (int index) { // Add onTap callback to update `_index`
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
