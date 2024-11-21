import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';
import 'income.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await initializeDateFormatting('ko_KR', null);
  // Intl.defaultLocale = 'ko_KR';
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HistoryPage(),
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('ko', 'KR')
      // ],
      // locale: const Locale('ko'),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);
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
  var f = NumberFormat('###,###,###,###');
  List<Map<String, dynamic>> transactions = [];
  Map<String, bool> isExpanded = {};


  void initState() {
    super.initState();
    loadTransactionsData();
    totaldata();
  }

  Future<void> loadTransactionsData() async {
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> expenseDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('expense')
          .where('year', isEqualTo: selectedYear)
          .where('month', isEqualTo: selectedMonth)
          .orderBy('date', descending: true)
          .get();

      QuerySnapshot<Map<String, dynamic>> incomeDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('income')
          .where('year', isEqualTo: selectedYear)
          .where('month', isEqualTo: selectedMonth)
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> loadedTransactions = [
        ...expenseDocs.docs.map((doc) {
          final data = doc.data();
          return {
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

      loadedTransactions.sort((a,b) {
        Timestamp dateA = a['date'] as Timestamp;
        Timestamp dateB = b['date'] as Timestamp;
        return dateB.compareTo(dateA);
      });

      setState(() {
        transactions = loadedTransactions;
      });
    }
  }

  Future<void> totaldata() async {       //추가
    int? totalExpense = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
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
        .doc(user!.uid)
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
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
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
                    _buildHeaderItem("수입", income != null ? f.format(income).toString() : "로딩 중", Colors.blue),
                    _buildHeaderItem("지출", expense != null ? f.format(expense).toString() : "로딩 중", Colors.red),
                    _buildHeaderItem("합계", total != null ? f.format(total).toString() : "로딩 중", Colors.black),
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
                          isExpense: transaction['type']  == 'expense',
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
        backgroundColor: Color(0xFFB1C3D1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputPage()),
          );
        },
        child: Icon(Icons.add),
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
            color: Color(0xFFB1C3D1),
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
                        color: Colors.black,
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
                    color: Colors.black,
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

  Widget _buildTransactionItem(String category, String memo, String amount, {bool isExpense = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey))
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
              memo ?? '메모 없음',
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
    );
  }

}
