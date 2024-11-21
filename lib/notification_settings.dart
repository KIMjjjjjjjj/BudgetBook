import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationSettingsPage(),
    );
  }
}

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool spendingWarning = true;
  bool regularSpending = true;
  bool roomInvitation = true;
  int selectedDay = 17;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            // 지출 경고 알림
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('지출 경고 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: spendingWarning,
                  onChanged: (val) => setState(() => spendingWarning = val),
                  activeColor: Colors.green,
                ),
              ],
            ),
            Divider(),
            // 정기 지출 알림
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('정기 지출 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: regularSpending,
                  onChanged: (val) => setState(() => regularSpending = val),
                  activeColor: Colors.green,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Icon(Icons.add, color: Colors.blue),
                  ),
                  onPressed: () {
                    setState(() {
                      //버튼 클릭 시 추가
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'NETFLIX',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Text('매월', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: selectedDay,
                  items: List.generate(31, (index) => index + 1)
                      .map((day) => DropdownMenuItem<int>(
                    value: day,
                    child: Text(day.toString()),
                  ))
                      .toList(),
                  onChanged: (day) {
                    setState(() {
                      selectedDay = day!;
                    });
                  },
                ),
                Text('일', style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      //버튼 클릭시 삭제
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Divider(),

            // 방 초대 알림
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('방 초대 알림', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Switch(
                      value: roomInvitation,
                      onChanged: (val) => setState(() => roomInvitation = val),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                Text('공유 가계부 초대 알림이 옵니다', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '내역'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '그래프'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: '예산 관리'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

