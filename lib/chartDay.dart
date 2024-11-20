import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartDayPage extends StatefulWidget{
  @override
  ChartDayState createState() => ChartDayState();
}

class ChartDayState extends State<ChartDayPage>{
  DateTime? selectedDate;
  List<PieChartSectionData> sections = [];
  String? userId;

  Map<String, double> expenseData = {};

  double totalExpenseAmount = 0.0;
  double totalIncomeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          userId = null; // 로그인한 사용자 ID 설정
        });
      } else {
        setState(() {
          userId = user.uid; // 로그인한 사용자 ID 설정
        });
        dataOfExpense(); // 데이터 가져오기
        dataOfIncome();
      }
    });
  }

  Future<void> dataOfIncome() async {
    if (selectedDate == null || userId == null) return;

    int year = selectedDate!.year;
    int month = selectedDate!.month;
    int day = selectedDate!.day;

    double totalIncomeAmount = 0.0;

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId) // 사용자 ID로 문서 지정
        .collection('income')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .where('day', isEqualTo: day)
        .get();

    for (var doc in snapshot.docs) {
      double incomeAmount = (doc['incomeAmount'] as int).toDouble();

      totalIncomeAmount += incomeAmount;
    }

    setState(() {
      this.totalIncomeAmount = totalIncomeAmount;
    });
  }


  final List<Color> colorPalette = [
    Colors.red,
    Colors.cyanAccent,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellowAccent,
    Colors.teal,
    Colors.brown,
    Colors.indigo,];

  Map<String, Color> categoryColorMap = {}; // 카테고리별 색상 저장

  Future<void> dataOfExpense() async {
    if (selectedDate == null || userId == null) return;

    int year = selectedDate!.year;
    int month = selectedDate!.month;
    int day = selectedDate!.day;

    expenseData.clear();
    double totalExpenseAmount = 0.0;

    // Firestore에서 데이터 가져오기
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId) // 사용자 ID로 문서 지정
        .collection('expense')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .where('day', isEqualTo: day)
        .get();

    for (var doc in snapshot.docs) {
      String category = doc['category']; // 카테고리 필드
      double expenseAmount = (doc['expenseAmount'] as int).toDouble();

      totalExpenseAmount += expenseAmount;

      if (expenseData.containsKey(category)) {
        expenseData[category] = (expenseData[category] ?? 0) + expenseAmount; // null 체크 후 더하기
      } else {
        expenseData[category] = expenseAmount; // 새로운 카테고리 추가
      }
    }



    setState(() {
      this.totalExpenseAmount = totalExpenseAmount;

      int colorIndex = 0;

      if(expenseData.isEmpty || totalExpenseAmount == 0){
        sections = [PieChartSectionData(color: Colors.grey, // 빈 데이터에 대한 색상
                    value: 1, // 최소값 설정
                    title: '데이터 없음', // 제목
                    radius: 130,),];
      } else {
        sections = expenseData.entries.map((entry) {
          // 카테고리별 색상 맵에 색상 추가
          if (!categoryColorMap.containsKey(entry.key)) {
            categoryColorMap[entry.key] = colorPalette[colorIndex % colorPalette.length];
            colorIndex++; // 색상 인덱스 증가
          }

          double percentage = (entry.value / totalExpenseAmount) * 100; // 비율 계산
          return PieChartSectionData(
            color: categoryColorMap[entry.key]!, // 고유한 색상 사용
            value: percentage, // 비율을 값으로 설정
            title: '${entry.key}: ${percentage.toStringAsFixed(1)}%', // 비율 표시
            radius: 130,
          );
        }).toList();
      }
    });
  }

  void _onButtonPressed(String period){
    dataOfExpense();
    dataOfIncome();
  }

  void selectDate() async {
    DateTime selectedDateTime = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != this.selectedDate) {
      setState(() {
        this.selectedDate = selectedDate; // 선택한 날짜 저장
      });
      dataOfExpense();
      dataOfIncome();
    }
  }

  Widget buttonLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: buildButton('오늘')),
        Expanded(child: buildButton('일간')),
        Expanded(child: buildButton('주간')),
        Expanded(child: buildButton('월간')),
      ],
    );
  }

  Widget buildButton(String label) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(label),
    );
  }

  Widget selectDateWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: selectDate,
          color: Colors.black, // 아이콘 색상
        ),
        SizedBox(width: 10),
        Text(
          selectedDate != null ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}' : '날짜 선택하기',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text('차트 페이지'),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          selectDateWidget(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0), // 하단 패딩을 0으로 설정
            child: buttonLine(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('총 수입', style: TextStyle(fontSize: 12)),
                        Text('${totalIncomeAmount.toInt()}원',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('총 지출', style: TextStyle(fontSize: 12)),
                        Text('${totalExpenseAmount.toInt()}원',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('총합계', style: TextStyle(fontSize: 12)),
                        Text('${(totalIncomeAmount - totalExpenseAmount).toInt()}원',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 원형 그래프 추가
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40, // 중앙 공간 반지름
              ),
            ),
          ),
          Container(
            height: 300, // 높이 250 설정
            padding: const EdgeInsets.all(0.0),
            color: Colors.indigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // 위아래 여백 추가
                        child: Text(
                          '카테고리',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // 위아래 여백 추가
                        child: Text(
                          '퍼센트',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // 위아래 여백 추가
                        child: Text(
                          '금액',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                // 카테고리 데이터 표시
                Expanded(
                  child: Container(
                    color: Colors.white, // 하얀색 배경
                    padding: const EdgeInsets.only(top: 5),
                    child: ListView(
                      children: [
                        for (var entry in expenseData.entries)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // 간격을 늘리기 위해 수직 패딩을 늘림
                            child : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                                        child: Text(entry.key, textAlign: TextAlign.end),
                                        // 카테고리 이름
                                      ),
                                    ),
                                    SizedBox(width: 40),
                                    Expanded(
                                        child: Text(
                                          '${((entry.value / totalExpenseAmount) * 100).toStringAsFixed(1)}%',
                                          textAlign: TextAlign.end, // 퍼센트 정렬
                                        ),
                                    ),
                                    SizedBox(width: 40),
                                    Expanded(
                                      child: Text(
                                        '${entry.value.toInt()}원',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(color: Colors.red),// 금액 정렬
                                      ),
                                    ),
                                    SizedBox(width: 50),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                  thickness: 1.0,
                                )
                              ],
                            )
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}