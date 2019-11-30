import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zerdaly_app/general.dart';
import 'package:zerdaly_app/register.dart';
import 'package:zerdaly_app/token.dart';
import 'package:zerdaly_app/user.dart';

class Login extends StatefulWidget {
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  final token = Token.instance;
  User user = new User();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool loginState = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Image.asset('images/login.png'),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Center(
                      child: Text(
                        "Zerdaly",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pacifico',
                          fontSize: MediaQuery.of(context).size.width / 8,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Innovando a través del ecommerce.",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontSize: MediaQuery.of(context).size.width / 23,
                        ),
                      ),
                    ),
                    //   Padding(padding: EdgeInsets.only(top: 10)),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            decoration: new BoxDecoration(
                              color: Colors.white,
                            ),
                            child: new TextField(
                              controller: email,
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: HexColor("#FF5757")),
                              decoration: new InputDecoration(
                                hintText: 'Email',
                                contentPadding: EdgeInsets.all(10),
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                              color: Colors.white,
                            ),
                            child: new TextField(
                              controller: password,
                              obscureText: true,
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: HexColor("#FF5757")),
                              decoration: new InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                hintText: 'Contraseña',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                          ),
                          !loginState
                              ? GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    height:
                                        MediaQuery.of(context).size.height / 16,
                                    decoration: BoxDecoration(
                                        color: HexColor("#FF5757")),
                                    child: Center(
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Kanit',
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                22),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (email.text.isEmpty) {
                                      errorMessage(
                                          "El campo del email no puede estar vacío.");
                                    } else if (password.text.isEmpty) {
                                      errorMessage(
                                          "El campo de la contraseña no puede estar vacío.");
                                    } else {
                                      login();
                                    }
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                )
                        ],
                      ),
                    ),

                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "¿No tienes una cuenta? ",
                          style: TextStyle(
                              fontFamily: 'Kanit', color: HexColor("#FF9052")),
                        ),
                        GestureDetector(
                          child: Text(
                            "Registrarme",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: HexColor("#FF5757")),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  errorMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: 'Kanit'),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  successMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: 'Kanit'),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  login() async {
    setState(() {
      loginState = true;
    });

    final result = await user.login(email.text, password.text);
    //Comprube que el login ha sido exitoso
    if (result[0] == "200") {
      setState(() {
        loginState = false;
      });
      //guardar token
     saveToken(result[2]);
    } else {
      errorMessage("Revisa el email y la contraseña e intentalo otra vez.");
      setState(() {
        loginState = false;
      });
    }
  }

    saveToken(String auth) async {
    Token token = Token.instance;
    Map<String, dynamic> row = {
      Token.columnAuth: auth
    };

    final id = await token.insert(row);

    if (id != null) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => General()));
    }
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
