
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RoomSelectionPage(),
    );
  }
}

class RoomSelectionPage extends StatefulWidget {
  @override
  RoomSelectionPageState createState() => RoomSelectionPageState();
}

class RoomSelectionPageState  extends State<RoomSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "가계부를 선택하세요",
               style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildRoomBox(
                    icon: Icons.person,
                    label: '개인방',
                    onPressed: () {
                      print('개인방');
                    },
                  ),
                  SizedBox(width: 20),
                  buildRoomBox(
                    icon: Icons.emoji_emotions,
                    label: '공유방',
                    onPressed: () {
                      print('공유방');
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              buildRoomBox(
                icon: Icons.add,
                label: '방 추가',
                onPressed: () {
                  print('방 추가');
                },
              )
            ],
          )
      ),
    );
  }

  Widget buildRoomBox({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        Material(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 70,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}