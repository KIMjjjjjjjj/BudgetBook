import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileproject/account/account.dart';
import '../account/Change/edit_profile.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class InputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _ExpenseIncomeDialog(context);
          },
          child: Text('버튼'),
        ),
      ),
    );
  }

  void _ExpenseIncomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    children: [
                      ExpensePage(),
                      IncomePage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  DateTime selectedDateTime = DateTime.now();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  String selectedCategory = '식비';
  String? errorMessage1;
  String? errorMessage2;

  bool ExpenseError() {
    final expense = expenseAmountController.text.trim();
    if (expense.isEmpty) {
      setState(() {
        errorMessage1 = null;
        errorMessage2 = '금액을 입력해주세요.';
      });
      return false;
    }

    if (int.tryParse(expense) == null) {
      setState(() {
        errorMessage1 = '금액은 정수로 입력해야 합니다.';
        errorMessage2 = null;
      });
      return false;
    }

    setState(() {
      errorMessage1 = null;
      errorMessage2 = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('지출 내역'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: '지출일',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.event),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          selectedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              controller: TextEditingController(
                text: DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: expenseAmountController,
              decoration: InputDecoration(
                labelText: '지출금액',
                border: OutlineInputBorder(),
                errorText: errorMessage1 ?? errorMessage2,
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '식비', child: Text('식비')),
                DropdownMenuItem(value: '교통비', child: Text('교통비')),
                DropdownMenuItem(value: '마트/편의점', child: Text('마트/편의점')),
                DropdownMenuItem(value: '패션/미용', child: Text('패션/미용')),
                DropdownMenuItem(value: '기타', child: Text('기타')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: memoController,
              decoration: InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: Text('취소'),
        ),
        SizedBox(width: 35),
        ElevatedButton(
          onPressed: () async {
            if (ExpenseError()) {
              final element = FirebaseAuth.instance.currentUser?.uid;
              CollectionReference subCollection = FirebaseFirestore.instance.collection('users').doc(element).collection('expense');
              await subCollection.add({
                'date': selectedDateTime,
                'expenseAmount': int.parse(expenseAmountController.text.trim()),
                'year' : selectedDateTime.year,
                'month' : selectedDateTime.month,
                'day' : selectedDateTime.day,
                'category': selectedCategory,
                'memo': memoController.text,
              });

              Navigator.pop(context);
            }
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage>{
  DateTime selectedDateTime = DateTime.now();
  final TextEditingController incomeAmountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  String selectedCategory = '식비';
  String? errorMessage1;
  String? errorMessage2;

  bool IncomeError() {
    final income = incomeAmountController.text.trim();
    if (income.isEmpty) {
      setState(() {
        errorMessage1 = null;
        errorMessage2 = '금액을 입력해주세요.';
      });
      return false;
    }

    if (int.tryParse(income) == null) {
      setState(() {
        errorMessage1 = '금액은 정수로 입력해야 합니다.';
        errorMessage2 = null;
      });
      return false;
    }

    setState(() {
      errorMessage1 = null;
      errorMessage2 = null;
    });
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('수입 내역'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '수입일',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.event),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          selectedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              controller: TextEditingController(
                text: DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: incomeAmountController,
              decoration: InputDecoration(
                labelText: '수입금액',
                border: OutlineInputBorder(),
                errorText: errorMessage1 ?? errorMessage2,
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '식비', child: Text('식비')),
                DropdownMenuItem(value: '교통비', child: Text('교통비')),
                DropdownMenuItem(value: '마트/편의점', child: Text('마트/편의점')),
                DropdownMenuItem(value: '패션/미용', child: Text('패션/미용')),
                DropdownMenuItem(value: '기타', child: Text('기타')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: memoController,
              decoration: InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('취소'),
        ),
        SizedBox(width: 35),
        ElevatedButton(
          onPressed: () async {
            if (IncomeError()) {
              final element = FirebaseAuth.instance.currentUser?.uid;
              CollectionReference subCollection = FirebaseFirestore.instance.collection('users').doc(element).collection('income');
              await subCollection.add({
                'date': selectedDateTime,
                'expenseAmount': int.parse(incomeAmountController.text.trim()),
                'year' : selectedDateTime.year,
                'month' : selectedDateTime.month,
                'day' : selectedDateTime.day,
                'category': selectedCategory,
                'memo': memoController.text,
              });

              Navigator.pop(context);
            }
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}
