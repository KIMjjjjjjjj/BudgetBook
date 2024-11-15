import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(
      MaterialApp(
          home: Scaffold(
              appBar: AppBar(
                  title: Text('신규 계정 등록')
              ),
              body:MyBody()

          )
      )
  );
}
class MyBody extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          MyWidget1(),
          MyWidget2(),
          MyWidget3(),
          MyWidget4(),
          MyWidget56(),
          MyWidget7(),

        ]
    );



  }
}

class MyWidget1 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
            children: <Widget>[

              Expanded(flex:1,child:Text('이메일 ',textAlign: TextAlign.center),),
              Expanded(flex:3,
                  child:TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: ' example@hansung.com',
                      contentPadding: EdgeInsets.symmetric(vertical: 3.0),),

                  )

              ),
              Expanded(flex:1,child: ElevatedButton(onPressed: (){}, child: Text("인증요청")))
              /*
                Widget을 넣을 위치
                */

            ]

        )
    );
  }
}
class MyWidget2 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
            children: <Widget>[

              Expanded(flex:1,child:Text('인증코드',textAlign: TextAlign.center),),
              Expanded(flex:3,
                  child:TextField(
                    style: TextStyle(fontSize: 10.0),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 3.0),),)),
              Expanded(flex:1,child: ElevatedButton(onPressed: (){}, child: Text("인증확인")))
              /*
                Widget을 넣을 위치
                */

            ]

        )
    );
  }

}
class MyWidget3 extends StatefulWidget{

  @override
  _MyWidget3State createState() => _MyWidget3State();




}

class _MyWidget3State extends State<MyWidget3>{
  bool _isValidNickName =true;
  final _idController = TextEditingController();
  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
            children: <Widget>[

              Expanded(
                flex: 1, child: Text('닉네임', textAlign: TextAlign.center),),
              Expanded(flex: 4,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          style: TextStyle(fontSize:10.0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderSide: BorderSide(color: _isValidNickName ?
                            Colors.grey : Colors.red,)),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                            isDense: true,

                          ),
                          onChanged: (text) {setState(() {
                            _isValidNickName = _validateNickName(text);
                          });},),
                        SizedBox(height: 4),
                        Text('한글 및 영어를 사용하여 10글자 이내 입력',
                          style: TextStyle(fontSize: 12, color: _isValidNickName?
                          Colors.grey : Colors.red),
                        ),

                      ]

                  )


                /*
                Widget을 넣을 위치
                */

              )

            ])
    );
  }
  bool _validateNickName(String text) {
    if (text.length > 10) {
      return false;
    }
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final codeUnit = char.codeUnitAt(0);

      // 한글 범위 (AC00 ~ D7AF) 또는 영어 범위 (0041 ~ 005A, 0061 ~ 007A) 확인
      if (!((codeUnit >= 0xAC00 && codeUnit <= 0xD7AF) ||
          (codeUnit >= 0x0041 && codeUnit <= 0x005A) ||
          (codeUnit >= 0x0061 && codeUnit <= 0x007A))) {
        return false; // 한글 또는 영어가 아닌 문자가 포함된 경우 false 반환
      }
    }

    return true; // 모든 문자가 한글 또는 영어인 경우 true 반환
  }
}




class MyWidget4 extends StatefulWidget {
  @override
  _MyWidget4State createState() => _MyWidget4State();


}
class _MyWidget4State extends State<MyWidget4> {
  bool _isValidId = true; // Track ID validity
  final _idController = TextEditingController(); // Add a controller

  @override
  void dispose() {
    _idController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text('아이디', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _idController, // Assign the controller
                    style: TextStyle(fontSize: 10.0),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isValidId ? Colors.grey : Colors.red, // Change border color
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      isDense: true,

                    ),
                    onChanged: (text) {
                      // Validate ID format
                      setState(() {
                        _isValidId =_validateId(text);
                      });
                    },
                  ),
                  SizedBox(height: 4),
                  Text(
                    '영문자 또는 숫자 포함하여 최소 6글자 이상',
                    style: TextStyle(fontSize: 12, color: _isValidId ? Colors.grey : Colors.red),

                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {},
              child: Text("중복확인"),
            ),
          ),
        ],
      ),
    );

  }
  bool _validateId(String text) {
    if (text.length < 6) {
      return false;
    }

    bool hasLetter = false;
    bool hasDigit = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char.contains(RegExp(r'[a-zA-Z]'))) {
        hasLetter = true;
      } else if (char.contains(RegExp(r'[0-9]'))) {
        hasDigit = true;
      }
    }

    return hasLetter || hasDigit; // 영문자 또는 숫자 중 하나만 포함되어도 true 반환
  }
}

class MyWidget56 extends StatefulWidget {

  @override
  _MyWidget56State createState() => _MyWidget56State();
}
class _MyWidget56State extends State<MyWidget56> {
  bool _isValidPassword = true;
  final _passwordController = TextEditingController();
  bool _isPasswordMatching = true;
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
              children: <Widget>[

                Expanded(
                  flex: 1, child: Text('비밀번호', textAlign: TextAlign.center),),
                Expanded(flex: 4,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _passwordController,
                            style: TextStyle(fontSize: 10.0),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderSide: BorderSide(
                                color: _isValidPassword ? Colors.grey : Colors
                                    .red,),),
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                              isDense: true,
                            ),
                            onChanged: (text) {
                              setState(() {
                                _isValidPassword = _validatePassword(text);
                              });
                            },),
                          SizedBox(height: 4),
                          Text('영문자/숫자/특수문자를 모두 포함하여 최소 8자 이상 입력',
                            style: TextStyle(
                                fontSize: 12, color: _isValidPassword ?
                            Colors.grey : Colors.red),),

                        ]

                    )


                  /*
                Widget을 넣을 위치
                */

                ),
          ],
        ),
    Row(
    children: <Widget>[
        Expanded(
                flex: 1,
                child: Text(
                  '비밀번호 확인',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.0),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _confirmPasswordController,
                      style: TextStyle(fontSize: 10.0),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isPasswordMatching ? Colors.grey : Colors.red,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        isDense: true,
                      ),
                      onChanged: (text) {
                        setState(() {
                          final password = _passwordController.text;
                          _isPasswordMatching = text == password;
                        });
                      },
                    ),
                    SizedBox(height: 2),
                    // 오류 메시지 표시 부분을 Column 위젯 안으로 이동
                    if (!_isPasswordMatching)
                      Text(
                        '비밀번호가 일치하지 않습니다',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ),
              ])


            ])
    );
  }
  // 비밀번호 유효성 검사 함수 추가
  bool _validatePassword(String text) {
    if (text.length < 8) {
      return false; // 최소 8자 이상인지 확인
    }
    bool hasLetter = false;
    bool hasDigit = false;
    bool hasSpecialChar = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char.contains(RegExp(r'[a-zA-Z]'))) {
        hasLetter = true;
      } else if (char.contains(RegExp(r'[0-9]'))) {
        hasDigit = true;
      } else if (char.contains(RegExp(r"""[!@#$%^&*()_+~`|}{:;"'<>,.?/-]""" )))
        hasSpecialChar = true;
    }
    return hasLetter && hasDigit && hasSpecialChar;
  }



}















class MyWidget7 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: EdgeInsets.all(8.0),
        child:
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: Text("회원가입"),
          ),

          /*
                Widget을 넣을 위치
                */



        )
    );
  }



}
