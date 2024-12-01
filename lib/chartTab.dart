import 'package:flutter/material.dart';
import 'chartToday.dart';
import 'chartDay.dart';
import 'chartWeek.dart';
import 'chartMonth.dart';

class TabBarSet extends StatefulWidget {
  final String elements;

  const TabBarSet({Key? key, required this.elements}) : super(key: key);

  @override
  TabBarState createState() => TabBarState();
}

class TabBarState extends State<TabBarSet> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            // AppBar의 제목을 제거
            bottom: TabBar(
              tabs: [
                Tab(text: "오늘"),
                Tab(text: "일간"),
                Tab(text: "주간"),
                Tab(text: "월간"),
              ],
            ),
            toolbarHeight: 10, // AppBar의 높이를 늘립니다.
          ),
          body: TabBarView(
            children: [
              ChartTodayPage(elements: widget.elements),
              ChartDayPage(elements: widget.elements),
              ChartWeekPage(elements: widget.elements),
              ChartMonthPage(elements: widget.elements),
            ],
          ),
        ),
      ),
    );
  }
}
