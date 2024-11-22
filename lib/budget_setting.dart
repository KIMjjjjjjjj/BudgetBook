import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetSetting extends StatefulWidget {
  @override
  _BudgetSettingState createState() => _BudgetSettingState();
}

class _BudgetSettingState extends State<BudgetSetting> {
  int totalSpent = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    TotalSpent();
  }

  Future<void> TotalSpent() async {
    int totalIncome = 0;
    int totalExpense = 0;

    DateTime now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

      QuerySnapshot<Map<String, dynamic>> expenseDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('expense')
          .where('year', isEqualTo: currentYear)
          .where('month', isEqualTo: currentMonth)
          .get();

      QuerySnapshot<Map<String, dynamic>> incomeDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('income')
          .where('year', isEqualTo: currentYear)
          .where('month', isEqualTo: currentMonth)
          .get();

      for (var doc in expenseDocs.docs) {
        Map<String, dynamic> data = doc.data();
        totalExpense += data['expenseAmount'] as int;
      }

      for (var doc in incomeDocs.docs) {
        Map<String, dynamic> data = doc.data();
        totalIncome += data['incomeAmount'] as int;
      }

      setState(() {
        totalSpent = totalExpense;
      });
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          '이번달 예산',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘까지 소비',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              '${totalSpent.toString()}원',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: totalSpent < 0 ? 0 : totalSpent / 1000000,
              color: totalSpent >= 0 ? Colors.red : Colors.green,
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '예산 설정',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    // 넣어야됨
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    backgroundColor: Colors.blue[100],
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size(45, 35),
                  ),
                  child: Text(
                    '수정',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text('원',
              style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold
              ),
            ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '남은 예산이 설정 금액에 도달할 시 알림이 갑니다',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}