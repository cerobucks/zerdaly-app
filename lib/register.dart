import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zerdaly_app/token.dart';
import 'package:zerdaly_app/user.dart';

import 'general.dart';

class Register extends StatefulWidget {
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final token = Token.instance;
  User user = new User();

  TextEditingController name = new TextEditingController();
  TextEditingController lastName = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController bday = new TextEditingController();
  TextEditingController bmonth = new TextEditingController();
  TextEditingController byear = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  String city = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool registerState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/register.png"), fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //   Padding(padding: EdgeInsets.only(top: 80)),
                Center(
                  child: Text(
                    "Registro",
                    style: TextStyle(
                      color: HexColor("#FF9052"),
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.width / 12,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width / 2.5,
                              decoration: new BoxDecoration(),
                              child: new TextField(
                                controller: name,
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                                decoration: new InputDecoration(
                                  hintText: 'Nombre',
                                  contentPadding: EdgeInsets.all(10),
                                  hintStyle: TextStyle(
                                      fontFamily: 'Kanit',
                                      color: HexColor("#FF5757")),
                                ),
                              )),
                          Spacer(),
                          Container(
                              width: MediaQuery.of(context).size.width / 2.5,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                              ),
                              child: new TextField(
                                controller: lastName,
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                                decoration: new InputDecoration(
                                  hintText: 'Apellido',
                                  contentPadding: EdgeInsets.all(10),
                                  hintStyle: TextStyle(
                                      fontFamily: 'Kanit',
                                      color: HexColor("#FF5757")),
                                ),
                              )),
                        ],
                      ),
                      Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                        ),
                        child: new TextField(
                          controller: email,
                          style: TextStyle(
                              fontFamily: 'Kanit', color: HexColor("#FF5757")),
                          decoration: new InputDecoration(
                            hintText: 'Email',
                            contentPadding: EdgeInsets.all(10),
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
                              fontFamily: 'Kanit', color: HexColor("#FF5757")),
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Contraseña',
                            hintStyle: TextStyle(
                                fontFamily: 'Kanit',
                                color: HexColor("#FF5757")),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                              child: DropdownButton<String>(
                                  items: <String>['San Pedro de Macoris']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontFamily: 'Kanit',
                                          color: HexColor("#FF5757"),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String res) {
                                    setState(() {
                                      city = res;
                                    });
                                  },
                                  hint: Text(
                                    city == "" ? "Tu ciudad" : city,
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        color: HexColor("#FF5757")),
                                  ))),
                        ],
                      ),
                      Container(
                          decoration: new BoxDecoration(
                            color: Colors.white,
                          ),
                          child: new TextField(
                            controller: phone,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: HexColor("#FF5757")),
                            maxLength: 10,
                            decoration: new InputDecoration(
                              hintText: 'Teléfono',
                              contentPadding: EdgeInsets.all(10),
                              hintStyle: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: HexColor("#FF5757")),
                              counterText: "",
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      Text(
                        "Fecha de nacimento",
                        style: TextStyle(
                          color: HexColor("#FF9052"),
                          fontFamily: 'Kanit',
                          fontSize: MediaQuery.of(context).size.width / 22,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width / 6,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                              ),
                              child: new TextField(
                                controller: bday,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                                maxLength: 2,
                                decoration: new InputDecoration(
                                  hintText: 'Día',
                                  contentPadding: EdgeInsets.all(10),
                                  hintStyle: TextStyle(
                                      fontFamily: 'Kanit',
                                      color: HexColor("#FF5757")),
                                  counterText: "",
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 6,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                              ),
                              child: new TextField(
                                controller: bmonth,
                                maxLength: 2,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                                decoration: new InputDecoration(
                                  hintText: 'Mes',
                                  contentPadding: EdgeInsets.all(10),
                                  hintStyle: TextStyle(
                                      fontFamily: 'Kanit',
                                      color: HexColor("#FF5757")),
                                  counterText: "",
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 4,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                              ),
                              child: new TextField(
                                controller: byear,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757")),
                                decoration: new InputDecoration(
                                  hintText: 'Año',
                                  contentPadding: EdgeInsets.all(10),
                                  hintStyle: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: HexColor("#FF5757"),
                                  ),
                                  counterText: "",
                                ),
                              )),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                      ),
                      !registerState
                          ? GestureDetector(
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: MediaQuery.of(context).size.height / 16,
                                decoration:
                                    BoxDecoration(color: HexColor("#FF5757")),
                                child: Center(
                                  child: Text(
                                    'Registrarme',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                22),
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (name.text.isEmpty ||
                                    lastName.text.isEmpty ||
                                    password.text.isEmpty ||
                                    phone.text.isEmpty ||
                                    city == "" ||
                                    bday.text.isEmpty ||
                                    bmonth.text.isEmpty ||
                                    byear.text.isEmpty ||
                                    city == null) {
                                  errorMessage(
                                      "Por favor, completa todos los campos.");
                                } else if (name.text.length < 4) {
                                  errorMessage(
                                      "El nombre debe tener por lo menos 4 letras.");
                                } else if (lastName.text.length < 4) {
                                  errorMessage(
                                      "El apellido debe tener por lo menos 4 letras.");
                                } else if (phone.text.length > 10 ||
                                    phone.text.length < 10) {
                                  errorMessage(
                                      "El número de telefono debe tener 10 digitos.");
                                } else if (byear.text.length != 4) {
                                  errorMessage("El año debe tener 4 digitos.");
                                } else if (int.parse(bday.text) > 31) {
                                  errorMessage(
                                      "Los meses no tienen más de 31 días.");
                                } else if (int.parse(bmonth.text) > 12) {
                                  errorMessage(
                                      "El año no tiene más de 12 meses.");
                                } else {
                                  DateTime now = new DateTime.now();
                                  var age = now.year - int.parse(byear.text);

                                  if (age < 18) {
                                    errorMessage(
                                        "Debes ser mayor de edad para registrarte.");
                                  } else {
                                    register();
                                  }
                                }
                              },
                            )
                          : CircularProgressIndicator()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
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

  register() async {
    setState(() {
      registerState = true;
    });
    var data = {
      'name': name.text,
      'lastname': lastName.text,
      'email': email.text.toLowerCase().toString(),
      'password': password.text,
      'dob': bday.text.toString() +
          "/" +
          bmonth.text.toString() +
          "/" +
          byear.text.toString(),
      'city': city,
      'phone': phone.text.toString(),
    };
    final result = await user.register(data);
    if (result[0] == 200) {
      saveToken(result[4]["token"].toString());
    } else if (result[0] == 404) {
      if (result[2]["email"] != null) {
        if (result[2]["email"][0] ==
            "The email must be a valid email address.") {
          errorMessage("Utiliza un email válido.");
        } else if ((result[2]["email"][0] ==
            "The email has already been taken.")) {
          errorMessage("Este email ya está en uso.");
        }
      } else {
        errorMessage("Ha ocurrido error, Intentalo de nuevo.");
      }
    } else {
      errorMessage("Ha ocurrido error, Intentalo de nuevo.");
    }

    setState(() {
      registerState = false;
    });
  }

  saveToken(String auth) async {
    Token token = Token.instance;
    Map<String, dynamic> row = {Token.columnAuth: auth};

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
