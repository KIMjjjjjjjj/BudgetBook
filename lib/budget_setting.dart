import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetSetting extends StatefulWidget {
  final String elements;

  const BudgetSetting({required this.elements});
  @override
  _BudgetSettingState createState() => _BudgetSettingState();
}

class _BudgetSettingState extends State<BudgetSetting> {
  int totalSpent = 0;
  int budgetAmount = 1;
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    TotalSpent();
    bringBudgetAmount();
  }

  Future<void> TotalSpent() async {
    int totalExpense = 0;

    DateTime now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

    QuerySnapshot<Map<String, dynamic>> expenseDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.elements)
        .collection('expense')
        .where('year', isEqualTo: currentYear)
        .where('month', isEqualTo: currentMonth)
        .get();

    QuerySnapshot<Map<String, dynamic>> incomeDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.elements)
        .collection('income')
        .where('year', isEqualTo: currentYear)
        .where('month', isEqualTo: currentMonth)
        .get();

    for (var doc in expenseDocs.docs) {
      Map<String, dynamic> data = doc.data();
      totalExpense += data['expenseAmount'] as int;
    }


    setState(() {
      totalSpent = totalExpense;
    });
  }

  Future<void> BudgetAmount(int amount) async {
    try {
      if (widget.elements == user?.uid) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .set({'budgetAmount': amount}, SetOptions(merge: true));
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('share')
            .where('방 이름', isEqualTo: widget.elements)
            .get();

        if (querySnapshot.docs.isEmpty) {
          print("공유방이 없습니다.");
          return;
        }

        final docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('share')
            .doc(docId)
            .set({'budgetAmount': amount}, SetOptions(merge: true));
      }

      print("budgetAmount 업데이트 성공");
    } catch (e) {
      print('Error saving budget amount: $e');
    }
  }

  Future<void> bringBudgetAmount() async {
    try {
      if (widget.elements == user?.uid) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();
        final budgetAmount = userDoc.data()?['budgetAmount'];
        setState(() {
          this.budgetAmount = budgetAmount ?? 0;
        });
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('share')
            .where('방 이름', isEqualTo: widget.elements)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final budgetAmount = doc.data()?['budgetAmount'];
          setState(() {
            this.budgetAmount = budgetAmount ?? 0;
          });
        } else {
          print("공유방이 없습니다.");
        }
      }
    } catch (e) {
      print('Error retrieving budget amount: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        title: Text(
          '이번달 예산',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text(
              '오늘까지 소비',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              '-${totalSpent.toString()} 원',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: (budgetAmount > 0) ? totalSpent / budgetAmount : 0,
              color: Color(0xFF800000),
              backgroundColor: Colors.grey[300],
              minHeight: 12,
            ),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '예산 설정',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    int newBudget = int.tryParse(budgetController.text) ?? 0;
                    setState(() {
                      budgetAmount = newBudget;
                    });
                    BudgetAmount(newBudget);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.indigoAccent[700],
                    backgroundColor: Colors.indigoAccent[100],
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size(45, 30),
                  ),
                  child: Text(
                    '수정',
                    style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: budgetController,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text('원',
                  style: TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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