import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zerdaly_app/general.dart';
import 'package:zerdaly_app/login.dart';
import 'package:zerdaly_app/token.dart';

void main() => runApp(new MaterialApp(
      theme: ThemeData(
          primaryColor: Color.fromRGBO(255, 144, 82, 1),
          accentColor: Color.fromRGBO(255, 144, 82, 1)),
      debugShowCheckedModeBanner: false,
      home: MySplashScreen(),
    ));

class MySplashScreen extends StatefulWidget {
  @override
  MySplashScreenState createState() => MySplashScreenState();
}

class MySplashScreenState extends State<MySplashScreen> {
  final token = Token.instance;

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 5), () => getUser());
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData screenInfo = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(255, 144, 82, 1)),
          ),
          Center(
            child: Text(
              "Zerdaly",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Pacifico',
                fontSize: screenInfo.size.width / 6,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  getUser() async {
    final rowCount = await token.queryAllRows();

    if (rowCount.length > 0) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => General()));
    } else {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }
}