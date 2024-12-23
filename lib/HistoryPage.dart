import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_settings.dart';


class HistoryPage extends StatefulWidget {
  final String elements;
  const HistoryPage({required this.elements});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final user = FirebaseAuth.instance.currentUser;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  String? category;
  String? memo;
  Timestamp? date;
  int? day;
  int? month;
  int? year;
  int? amount;
  int? expense;
  int? income;
  int? total;
  int? budgetAmount;
  var f = NumberFormat('###,###,###,###');
  List<Map<String, dynamic>> transactions = [];
  Map<String, bool> isExpanded = {};


  @override
  void initState() {
    super.initState();
    loadTransactionsData();
    totaldata();
    fetchBudget();
    Timer.periodic(Duration(seconds: 1), (timer) async {
      await totaldata();
      await loadTransactionsData();
    });
  }

  Future<void> totaldata() async {
    int? totalExpense = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.elements)
        .collection('expense')
        .where('year', isEqualTo: selectedYear)
        .where('month', isEqualTo: selectedMonth)
        .aggregate(sum('expenseAmount'))
        .get()
        .then((AggregateQuerySnapshot aggregateSnapshot) {
      return aggregateSnapshot.getSum('expenseAmount')?.toInt();
    });

    int? totalIncome = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.elements)
        .collection('income')
        .where('year', isEqualTo: selectedYear)
        .where('month', isEqualTo: selectedMonth)
        .aggregate(sum('incomeAmount'))
        .get()
        .then((AggregateQuerySnapshot aggregateSnapshot) {
      return aggregateSnapshot.getSum('incomeAmount')?.toInt();
    });

    setState(() {
      expense = totalExpense;
      income = totalIncome;
      total = totalIncome! - totalExpense!;
    });
  }

  Future<void> deleteTransaction(String collection, String docId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                '이 내역을 삭제하시겠습니까?',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                ),
              ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // '취소' 버튼의 텍스트 색상
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // 취소
              },
              child: Text('취소'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigoAccent, // '삭제' 버튼의 텍스트 색상
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // 삭제 확인
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );


    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.elements)
            .collection(collection)
            .doc(docId)
            .delete();
        await loadTransactionsData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내역이 삭제되었습니다.')),
        );
      } catch (e) {
        print("Error deleting transaction: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> loadTransactionsData() async {
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> expenseDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.elements)
          .collection('expense')
          .where('year', isEqualTo: selectedYear)
          .where('month', isEqualTo: selectedMonth)
          .orderBy('date', descending: true)
          .get();

      QuerySnapshot<Map<String, dynamic>> incomeDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.elements)
          .collection('income')
          .where('year', isEqualTo: selectedYear)
          .where('month', isEqualTo: selectedMonth)
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> loadedTransactions = [
        ...expenseDocs.docs.map((doc) {
          final data = doc.data();
          return {
            'docId': doc.id,
            'date': data['date'],
            'day': data['day'] ?? 0,
            'month': data['month'] ?? 0,
            'year': data['year'] ?? 0,
            'category': data['category'] ?? '',
            'memo': data['memo'] ?? '',
            'amount': data['expenseAmount'] ?? 0,
            'type': 'expense',
          };
        }).toList(),
        ...incomeDocs.docs.map((doc) {
          final data = doc.data();
          return {
            'docId': doc.id,
            'date': data['date'],
            'day': data['day'] ?? 0,
            'month': data['month'] ?? 0,
            'year': data['year'] ?? 0,
            'category': data['category'] ?? '',
            'memo': data['memo'] ?? '',
            'amount': data['incomeAmount'] ?? 0,
            'type': 'income',
          };
        }).toList(),
      ];

      loadedTransactions.sort((a, b) {
        Timestamp dateA = a['date'] as Timestamp;
        Timestamp dateB = b['date'] as Timestamp;
        return dateB.compareTo(dateA);
      });

      setState(() {
        transactions = loadedTransactions;
      });

      final prefs = await SharedPreferences.getInstance();
      final spendingWarning = prefs.getBool('spendingWarning') ?? true;
      final hasAlerted = prefs.getBool('hasAlerted') ?? false;

      print("Current Expense: $expense, Budget: $budgetAmount, HasAlerted: $hasAlerted");
      if (spendingWarning &&
          !hasAlerted &&
          expense != null &&
          budgetAmount != null &&
          expense! > budgetAmount!) {
        NotificationSettingsPageState.showNotification(
          title: '지출 경고 알림',
          body: '총 지출이 설정한 예산을 초과했습니다.',
        );

        await prefs.setBool('hasAlerted', true);
      }

      if (expense != null && budgetAmount != null && expense! <= budgetAmount!) {
        await prefs.setBool('hasAlerted', false);
      }
    }
  }

  void fetchBudget() async {
    try {
      if (widget.elements == user?.uid) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.elements)
            .get();

        if (userDoc.exists && userDoc.data()?['budgetAmount'] != null) {
          final userBudget = userDoc.data()?['budgetAmount'];
          setState(() {
            this.budgetAmount = userBudget;
          });
          print("Budget from users: $userBudget");
          return;
        }
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('share')
            .where('방 이름', isEqualTo: widget.elements)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final sharedBudget = doc.data()?['budgetAmount'];

          setState(() {
            this.budgetAmount = sharedBudget;
          });
          print("Budget from share: $sharedBudget");
        } else {
          print("No matching document in share collection.");
        }
      }
    } catch (e) {
      print("Error fetching budget: $e");
    }
  }


  Map<String, List<Map<String, dynamic>>> groupTransactionsByDay(List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      String day = transaction['day']?.toString() ?? '';
      if (groupedTransactions.containsKey(day)) {
        groupedTransactions[day]!.add(transaction);
      } else {
        groupedTransactions[day] = [transaction];
      }
    }
    return groupedTransactions;
  }

  int totalAmountForTheDay(int targetDay, List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> groupedExpenses = groupTransactionsByDay(transactions);
    List<Map<String, dynamic>>? dayTransactions  = groupedExpenses[targetDay.toString()];

    if (dayTransactions  == null || dayTransactions .isEmpty) {
      return 0;
    }
    int totalAmount = 0;
    for (var transaction in dayTransactions ) {
      if(transaction['type'] == 'expense') {
        totalAmount -= transaction['amount'] as int? ?? 0;
      } else if(transaction['type'] == 'income') {
        totalAmount += transaction['amount'] as int? ?? 0;
      }
    }
    return totalAmount;
  }

  String _getDayOfWeek(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    dateTime = dateTime.toLocal();
    return DateFormat('EEEE').format(dateTime);
    // return DateFormat('EEEE', 'ko').format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFEFF4),
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Row(
          children: [
            DropdownButton<int>(
              value: selectedYear,
              items: List.generate(5, (index) => DateTime.now().year - index)
                  .map((year) => DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              ))
                  .toList(),
              onChanged: (year) async {
                setState(() {
                  selectedYear = year!;
                });
                await loadTransactionsData();
                await totaldata();
              },
            ),
            SizedBox(width: 10),
            DropdownButton<int>(
              value: selectedMonth,
              items: List.generate(12, (index) => index + 1)
                  .map((month) => DropdownMenuItem<int>(
                value: month,
                child: Text(month.toString()),
              ))
                  .toList(),
              onChanged: (month) async {
                setState(() {
                  selectedMonth = month!;
                });
                await loadTransactionsData();
                await totaldata();
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderItem("수입", income != null ? f.format(income).toString() : "로딩 중", Colors.blue), //추가
                  _buildHeaderItem("지출", expense != null ? f.format(expense).toString() : "로딩 중", Colors.red), //추가
                  _buildHeaderItem("합계", total != null ? f.format(total).toString() : "로딩 중", Colors.black), //추가
                ],
              ),
            ),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                child: Text(
                  "No expense found.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView(
                children: groupTransactionsByDay(transactions).entries.map((entry) {
                  String day = entry.key;
                  List<Map<String, dynamic>> dayTransactions = entry.value;

                  return _buildDateSection(
                    '$day일',
                    _getDayOfWeek(dayTransactions.first['date'] as Timestamp),
                    '${totalAmountForTheDay(int.parse(day), dayTransactions).toString()}원',
                    dayTransactions.map((transaction) {
                      return _buildTransactionItem(
                        transaction['category'] ?? '',
                        transaction['memo'] ?? '',
                        '${transaction['amount']?.toString() ?? '0'}원',
                        transaction['docId'] ?? '', // 여기에 docId 추가
                        isExpense: transaction['type'] == 'expense',
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      //navigationBar
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        onPressed: () {
          _ExpenseIncomeDialog(context, widget.elements);
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14)),
        Text(amount, style: TextStyle(fontSize: 15, color: color)),
      ],
    );
  }

  Widget _buildDateSection(String day, String weekday, String totalAmount, List<Widget> expenses) {
    Color weekdayBackgroundColor;

    switch (weekday) {
      case "Sunday":
        weekdayBackgroundColor = Colors.red[300]!;
        break;
      case "Saturday":
        weekdayBackgroundColor = Colors.blue[300]!;
        break;
      default:
        weekdayBackgroundColor = Colors.grey[600]!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded[day] = !(isExpanded[day] ?? false);
            });
          },
          child: Container(
            color: Colors.indigoAccent,
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: weekdayBackgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  totalAmount,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded[day] ?? true)
          ListView(
            shrinkWrap: true,
            children: expenses,
          ),
        SizedBox(height: 7),
      ],
    );
  }

  Widget _buildTransactionItem(String category, String memo, String amount, String docId,
      {bool isExpense = false}) {
    return GestureDetector(
      onTap: () async {
        String collection = isExpense ? 'expense' : 'income';
        await deleteTransaction(collection, docId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                category,
                style: TextStyle(fontSize: 13.0),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                memo.isNotEmpty ? memo : ' ',
                style: TextStyle(fontSize: 13.0),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 14.0,
                  color: isExpense ? Colors.red : Colors.blue,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
  }


void _ExpenseIncomeDialog(BuildContext context, String elements) {
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
                    ExpensePage(elements: elements),
                    IncomePage(elements: elements),
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

class ExpensePage extends StatefulWidget {
  final String elements;

  const ExpensePage({required this.elements});
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
              CollectionReference subCollection = FirebaseFirestore.instance.collection('users').doc(widget.elements).collection('expense');
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
  final String elements;
  const IncomePage({required this.elements});
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage>{
  DateTime selectedDateTime = DateTime.now();
  final TextEditingController incomeAmountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  String selectedCategory = '월급';
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
                DropdownMenuItem(value: '월급', child: Text('월급')),
                DropdownMenuItem(value: '이체', child: Text('이체')),
                DropdownMenuItem(value: '금융소득', child: Text('금융소득')),
                DropdownMenuItem(value: '용돈', child: Text('용돈')),
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
              CollectionReference subCollection = FirebaseFirestore.instance.collection('users').doc(widget.elements).collection('income');
              await subCollection.add({
                'date': selectedDateTime,
                'incomeAmount': int.parse(incomeAmountController.text.trim()),
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
