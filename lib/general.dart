import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:zerdaly_app/main.dart';
import 'package:zerdaly_app/token.dart';
import 'package:zerdaly_app/user.dart';
import 'package:image_picker/image_picker.dart';

import 'package:compressimage/compressimage.dart';

class General extends StatefulWidget {
  GeneralState createState() => GeneralState();
}

class GeneralState extends State<General> {
  final token = Token.instance;
  User user = new User();

  var userInfo, orders, randomProducts, randomProducts2;
  final userUrl = "https://api.zerdaly.com/api/user/getimage/";
  final productUrl = 'https://api.zerdaly.com/api/business/getimage/product/';
  final businessUrl = "https://api.zerdaly.com/api/business/getimage/";

  int pages = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController searchKey = new TextEditingController();

  @override
  void initState() {
    super.initState();

    getUserInfo();
  }

  getUserInfo() async {
    final result = await token.queryAllRows();
    final auth = result[0]["Auth"];
    final response = await user.info(auth);

    setState(() {
      userInfo = response[1];
      orders = response[2];
    });

    getRandomProducts();
    getNotificationToken();
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();

  getNotificationToken() async {
    String fcmToken = await _fcm.getToken();

    if (userInfo["notification_token"] == null) {
      var data = json.encode({
        'notification_token': fcmToken,
      });

      final auth = await token.queryAllRows();

      await user.update(data, auth[0]['Auth']);
    } else if (fcmToken != userInfo["notification_token"]) {
      var data = json.encode({
        'notification_token': fcmToken,
      });

      final auth = await token.queryAllRows();

      await user.update(data, auth[0]['Auth']);
    }
  }

  getRandomProducts() async {
    final result = await token.queryAllRows();
    final auth = result[0]["Auth"];
    final response = await user.getRandomProducts(auth);
    final response2 = await user.getRandomProducts(auth);

    setState(() {
      randomProducts = response[2];
      randomProducts2 = response2[2];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (pages != 0) {
          getUserInfo();
          setState(() {
            pages = 0;
          });
        }
        return false;
      },
      child: page(),
    );
  }

  Widget page() {
    switch (pages) {
      case 0:
        return general();
      case 1:
        return productView();
      case 2:
        return profile();
      case 3:
        return locations();
      case 4:
        return newLocation();
      case 5:
        return updateLocation();
      case 6:
        return categorySearch();
      case 7:
        return searchPage();
      case 8:
        return businessPage();
      case 9:
        return buyNow();
      case 10:
        return thanksForBuying();
      case 11:
        return productsBought();
      case 12:
        return productBougthDetails();
      case 13:
        return updateProfile();
    }
    return Container();
  }

  Widget general() {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: userInfo != null
                      ? userInfo["image"] == null
                          ? Icon(
                              Icons.person,
                              color: HexColor("#ff9052"),
                              size: 40.0,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          userUrl + userInfo["image"]))),
                            )
                      : Icon(
                          Icons.store,
                          color: Colors.grey,
                          size: 40.0,
                        ),
                ),
                accountName: Text(
                  userInfo != null
                      ? userInfo["name"] + " " + userInfo["lastname"]
                      : "",
                  style: TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                ),
                accountEmail: Text(
                  userInfo != null ? userInfo["email"] : "",
                  style: TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: HexColor("#ff9052"),
                ),
                title: Text("General",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Kanit',
                        fontSize: 18)),
                onTap: () {
                  getUserInfo();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.shopping_basket,
                  color: HexColor("#ff9052"),
                ),
                title: Text("Pedidos",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Kanit',
                        fontSize: 18)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    pages = 11;
                  });
                },
              ),
              // ListTile(
              //   leading: Icon(
              //     Icons.shopping_cart,
              //     color: HexColor("#ff9052"),
              //   ),
              //   title: Text("Carrito",
              //       style: TextStyle(
              //           color: Colors.grey[500],
              //           fontFamily: 'Kanit',
              //           fontSize: 18)),
              //   onTap: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
              ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: HexColor("#ff9052"),
                ),
                title: Text("Perfil",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Kanit',
                        fontSize: 18)),
                onTap: () {
                  setState(() {
                    pages = 2;
                  });
                  Navigator.of(context).pop();
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Color.fromRGBO(255, 144, 82, 1),
                ),
                title: Text("Cerrar sesión",
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
                onTap: () async {
                  final id = await token.queryAllRows();
                  await token.delete(id[0]['id']);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MySplashScreen()));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: Color.fromRGBO(255, 144, 82, 1),
                ),
                title: Text("Términos y Condiciones",
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
              )
            ],
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.27,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.21,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          HexColor("#ff9052"),
                          HexColor("#ff5757"),
                        ],
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.78,
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Icon(
                                        Icons.menu,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        color: HexColor("#ff5757"),
                                      ),
                                      onTap: () {
                                        _scaffoldKey.currentState.openDrawer();
                                      },
                                    ),
                                    Spacer(),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.50,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      color: Colors.white,
                                      child: TextField(
                                        controller: searchKey,
                                        style: TextStyle(
                                            fontFamily: 'Kanit',
                                            color: HexColor("ff5757")),
                                        decoration: InputDecoration(
                                            hintText: "Buscar...",
                                            hintStyle: TextStyle(
                                                fontFamily: 'Kanit',
                                                color: HexColor("ff5757")),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 5, top: 5)),
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.search,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        color: HexColor("#ff5757"),
                                      ),
                                      onTap: () {
                                        if (searchKey.text.isNotEmpty) {
                                          userSearchKey(searchKey.text);
                                        }
                                      },
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Center(
                                  child: GestureDetector(
                                child: Icon(
                                  Icons.shopping_basket,
                                  size:
                                      MediaQuery.of(context).size.width * 0.08,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  setState(() {
                                    pages = 11;
                                  });
                                },
                              )),
                              Spacer()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.12,
                          left: 10,
                          right: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Categorías",
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.10,
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: <Widget>[
                                      Spacer(),
                                      GestureDetector(
                                        child: Column(
                                          children: <Widget>[
                                            Icon(
                                              Icons.headset,
                                              color: HexColor("#ff5757"),
                                            ),
                                            Text(
                                              "Accesorios",
                                              style: TextStyle(
                                                  fontFamily: 'Kanit',
                                                  color: Colors.grey,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.03),
                                            )
                                          ],
                                        ),
                                        onTap: () async {
                                          final auth =
                                              await token.queryAllRows();
                                          getCategory(1, auth[0]["Auth"]);
                                        },
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          child: Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.color_lens,
                                                color: HexColor("#ff5757"),
                                              ),
                                              Text(
                                                "Belleza",
                                                style: TextStyle(
                                                    fontFamily: 'Kanit',
                                                    color: Colors.grey,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03),
                                              )
                                            ],
                                          ),
                                          onTap: () async {
                                            final auth =
                                                await token.queryAllRows();
                                            getCategory(2, auth[0]["Auth"]);
                                          }),
                                      Spacer(),
                                      GestureDetector(
                                          child: Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.fastfood,
                                                color: HexColor("#ff5757"),
                                              ),
                                              Text(
                                                "Comida",
                                                style: TextStyle(
                                                    fontFamily: 'Kanit',
                                                    color: Colors.grey,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03),
                                              )
                                            ],
                                          ),
                                          onTap: () async {
                                            final auth =
                                                await token.queryAllRows();
                                            getCategory(3, auth[0]["Auth"]);
                                          }),
                                      Spacer(),
                                      GestureDetector(
                                          child: Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.accessibility_new,
                                                color: HexColor("#ff5757"),
                                              ),
                                              Text(
                                                "Vestimentas",
                                                style: TextStyle(
                                                    fontFamily: 'Kanit',
                                                    color: Colors.grey,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03),
                                              )
                                            ],
                                          ),
                                          onTap: () async {
                                            final auth =
                                                await token.queryAllRows();
                                            getCategory(4, auth[0]["Auth"]);
                                          }),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.33,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      HexColor("#ff9052"),
                      HexColor("#ff5757"),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Productos de interés",
                        style: TextStyle(
                            fontFamily: 'Kanit',
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.04)),
                    horizontalRandomProducts(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10),
              child: Text("Más productos",
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      color: HexColor("#ff9052"),
                      fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      randomProducts2 != null ? randomProducts2.length : 0,
                  itemBuilder: (BuildContext context, int i) => GestureDetector(
                    child: Card(
                      child: Center(
                          child: Column(
                        children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.50,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(productUrl +
                                          randomProducts2[i]["image"]
                                              .toString()))),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    color: Colors.white70,
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: <Widget>[
                                          Text(randomProducts2[i]["name"],
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: "Kanit")),
                                          Spacer(),
                                          Text(
                                              "\$" +
                                                  randomProducts2[i]["price"]
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: "Kanit")),
                                        ],
                                      ),
                                    )),
                              ))
                        ],
                      )),
                    ),
                    onTap: () {
                      getBusiness(randomProducts2[i]["business_id"]);
                      getProductLike(randomProducts2[i]["id"]);
                      setState(() {
                        productViewData = randomProducts2[i];
                        pages = 1;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget horizontalRandomProducts() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: randomProducts != null ? randomProducts.length : 0,
              itemBuilder: (BuildContext context, int i) => GestureDetector(
                child: Card(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 0.44,
                          height: MediaQuery.of(context).size.height * 0.237,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(productUrl +
                                      randomProducts[i]["image"].toString()))),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                color: Colors.white70,
                                child: Padding(
                                  padding: EdgeInsets.all(1),
                                  child: Row(
                                    children: <Widget>[
                                      Text(randomProducts[i]["name"],
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              fontFamily: "Kanit")),
                                      Spacer(),
                                      Text(
                                          "\$" +
                                              randomProducts[i]["price"]
                                                  .toString(),
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              fontFamily: "Kanit")),
                                    ],
                                  ),
                                )),
                          ))
                    ],
                  )),
                ),
                onTap: () {
                  getBusiness(randomProducts[i]["business_id"]);
                  getProductLike(randomProducts[i]["id"]);
                  setState(() {
                    productViewData = randomProducts[i];
                    pages = 1;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  var productViewData, businessDetails;

  Widget productView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 5),
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(productUrl + productViewData["image"]),
                ),
              )),
          Card(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        productViewData["name"],
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontFamily: 'Kanit'),
                      ),
                      Spacer(),
                      GestureDetector(
                        child: Icon(
                          productlikeStatus
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: HexColor("#ff5757"),
                        ),
                        onTap: () {
                          productLike(productViewData["id"]);
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "\$" + productViewData["price"].toString(),
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontFamily: 'Kanit'),
                      ),
                      Spacer(),
                      Text(
                        "Envío: \$" + shippingPrice.toString(),
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontFamily: 'Kanit'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Text(
                    "Detalles",
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        fontFamily: 'Kanit'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Text(
                    productViewData["description"],
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        fontFamily: 'Kanit'),
                  ),
                  Divider(),
                  GestureDetector(
                    child: Row(
                      children: <Widget>[
                        businessDetails != null
                            ? businessDetails[0]["image"] == null
                                ? Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.10,
                                    height: MediaQuery.of(context).size.width *
                                        0.10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: HexColor("#ff9052"),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.store,
                                        color: Colors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.10,
                                    height: MediaQuery.of(context).size.width *
                                        0.10,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(businessUrl +
                                                businessDetails[0]["image"]))),
                                  )
                            : Container(),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                        ),
                        Text(
                          businessDetails != null
                              ? businessDetails[0]["business_name"]
                              : "",
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontFamily: 'Kanit'),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        pages = 8;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Row(
                    children: <Widget>[
                      // GestureDetector(
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width * 0.58,
                      //     height: MediaQuery.of(context).size.height * 0.06,
                      //     color: HexColor("#ff9052"),
                      //     child: Center(
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: <Widget>[
                      //           Text(
                      //             "Agregar al ",
                      //             style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize:
                      //                     MediaQuery.of(context).size.width *
                      //                         0.03,
                      //                 fontFamily: 'Kanit'),
                      //           ),
                      //           Icon(
                      //             Icons.shopping_cart,
                      //             color: Colors.white,
                      //             size:
                      //                 MediaQuery.of(context).size.width * 0.05,
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     print("add to cart");
                      //   },
                      // ),
                      Spacer(),
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: MediaQuery.of(context).size.height * 0.06,
                          color: HexColor("#ff9052"),
                          child: Center(
                            child: Text(
                              "Comprar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  fontFamily: 'Kanit'),
                            ),
                          ),
                        ),
                        onTap: () {
                          getLocation();
                          setState(() {
                            locationDetails = null;
                            chosenDirection = null;
                            paymentStatus = false;
                            pages = 9;
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String shippingPrice = "";
  var businessProducts;
  bool localShipping = false;
  getBusiness(int id) async {
    setState(() {
      businessDetails = null;
      businessProducts = null;
      shippingPrice = "";
    });
    final auth = await token.queryAllRows();
    final response = await user.getBusiness(id, auth[0]["Auth"]);
    setState(() {
      businessDetails = response[2];
      businessProducts = response[3];
    });

    if (userInfo["city"] != businessDetails[0]["city"]) {
      setState(() {
        shippingPrice = businessDetails[0]["shipping_price"].toString();
      });
    } else {
      setState(() {
        shippingPrice = "60-100";
        localShipping = true;
      });
    }
  }

  bool productlikeStatus = false;
  getProductLike(int id) async {
    setState(() {
      productlikeStatus = false;
    });
    final auth = await token.queryAllRows();
    final response = await user.getProductLike(id, auth[0]["Auth"]);
    if (response[0] == "200") {
      if (response[2].length > 0) {
        setState(() {
          productlikeStatus = true;
        });
      }
    }
  }

  productLike(int id) async {
    if (productlikeStatus) {
      setState(() {
        productlikeStatus = false;
      });

      final auth = await token.queryAllRows();
      final response = await user.unlikeProduct(id, auth[0]["Auth"]);
    } else {
      setState(() {
        productlikeStatus = true;
      });

      final auth = await token.queryAllRows();
      final response = await user.likeProduct(id, auth[0]["Auth"]);
    }
  }

  var chosenDirection;
  var cardNumber = new MaskedTextController(mask: '0000 0000 0000 0000');
  var cardDate = new MaskedTextController(mask: '00/00');
  var cardCVV = new MaskedTextController(mask: '0000');

  Widget buyNow() {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Zerdaly",
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                color: Colors.white,
                fontFamily: "Pacifico"),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 5, left: 10),
                child: Text(
                  "Comprar",
                  maxLines: 1,
                  style: TextStyle(
                      color: HexColor("#ff9052"),
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.025),
                )),
            Divider(),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  chosenDirection == null ? "Elige una ubicación" : "Ubicación",
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                )),
            chosenDirection == null
                ? locationsInfo != null
                    ? locationsInfo.length > 0
                        ? SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.13,
                                  width:
                                      MediaQuery.of(context).size.width * 0.50,
                                  child: ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: locationsInfo != null
                                        ? locationsInfo.length
                                        : 0,
                                    itemBuilder:
                                        (BuildContext context, int i) =>
                                            GestureDetector(
                                      child: Card(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                locationsInfo[i]["city"],
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontFamily: 'Kanit',
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.02),
                                              ),
                                              Text(
                                                "Detalles",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontFamily: 'Kanit',
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.015),
                                              ),
                                              Text(
                                                locationsInfo[i]["description"],
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontFamily: 'Kanit',
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.015),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        calculateShipping(locationsInfo[i]);
                                        setState(() {
                                          chosenDirection = locationsInfo[i];
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text("Crea una ubicación llendo a Perfil.",
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.grey[600],
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                )),
                          ))
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                : Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.12,
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.92,
                                  child: Row(
                                    children: <Widget>[
                                      Text(chosenDirection["city"],
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontFamily: 'Kanit',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02)),
                                      Spacer(),
                                      GestureDetector(
                                        child: Icon(Icons.edit,
                                            color: HexColor("#ff9052"),
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03),
                                        onTap: () {
                                          setState(() {
                                            chosenDirection = null;
                                            shippingCost = 0;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.92,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Detalles",
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontFamily: 'Kanit',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015)),
                                      Text(
                                          chosenDirection["description"] == null
                                              ? " "
                                              : chosenDirection["description"]
                                                  .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontFamily: 'Kanit',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015))
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Detalles",
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                )),
            Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                productViewData["name"],
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                              ),
                              Spacer(),
                              Text(
                                "\$" + productViewData["price"].toString(),
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Envío",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                              ),
                              Spacer(),
                              Text(
                                "\$" + shippingCost.toString(),
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Text(
                                "Total",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                              ),
                              Spacer(),
                              Text(
                                "\$" +
                                    (productViewData["price"] + shippingCost)
                                        .toString(),
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                              )
                            ],
                          )
                        ],
                      )),
                )),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Pago",
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                )),
            Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                width: MediaQuery.of(context).size.width,
                child: Card(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.42,
                                  child: TextField(
                                    controller: cardNumber,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '4245 4245 4245 4245',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.18,
                                  child: TextField(
                                    controller: cardDate,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '02/22',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.18,
                                  child: TextField(
                                    controller: cardCVV,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'CVV',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )))),
            !paymentStatus
                ? GestureDetector(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: Center(
                        child: Card(
                          color: HexColor("#ff9052"),
                          child: Center(
                            child: Text(
                              'Comprar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Kanit',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (cardNumber.text.isEmpty ||
                          cardDate.text.isEmpty ||
                          cardCVV.text.isEmpty) {
                        errorMessage("Por favor, completa todos los campos.");
                      } else if (chosenDirection == null) {
                        errorMessage("Eligue una ubicación.");
                      } else if (cardNumber.text.length < 19) {
                        errorMessage(
                            "El número de la tarjeta esta incompleto.");
                      } else if (cardDate.text.length < 5) {
                        errorMessage("La fecha valida esta incompleta.");
                      } else if (cardCVV.text.length < 3) {
                        errorMessage("El CVV esta incompleto.");
                      } else {
                        placeOrder();
                      }
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )
          ],
        ));
  }

  int shippingCost = 0;
  calculateShipping(var direction) async {
    if (localShipping) {
      print(businessDetails[0]["city"]);
      if (direction["city"] == businessDetails[0]["city"]) {
        double distanceInMeters = await Geolocator().distanceBetween(
            direction["latitude"],
            direction["longitude"],
            businessDetails[0]["latitude"],
            businessDetails[0]["longitude"]);

        if (distanceInMeters < 2000) {
          shippingCost = 60;
        } else if (distanceInMeters > 2000 && distanceInMeters < 3500) {
          shippingCost = 80;
        } else {
          shippingCost = 100;
        }
      } else {
        shippingCost = businessDetails[0]["shipping_price"];
      }
    } else {
      shippingCost = businessDetails[0]["shipping_price"];
    }
    setState(() {});
  }

  bool paymentStatus = false;

  placeOrder() async {
    setState(() {
      paymentStatus = true;
    });
    //Split card number
    var number = cardNumber.text.split(" ");
    String numberSplit = number[0] + number[1] + number[2] + number[3];
    //Split card date
    var date = cardDate.text.split("/");
    String month = date[0];
    String year = date[1];

    //create subscription
    final result = await token.queryAllRows();
    final auth = result[0]["Auth"];

    if (businessDetails[0]["city"] == chosenDirection["city"]) {
      setState(() {
        localShipping = true;
      });
    }

    List productList = new List(1);
    productList[0] = productViewData;

    var data = json.encode({
      'user_id': userInfo["id"],
      'business_id': businessDetails[0]["id"],
      'user_location_id': chosenDirection["id"],
      'products_id': json.encode(productList),
      'products_total': productViewData["price"].toString(),
      'business_total':
          (productViewData["price"] - ((productViewData["price"] * 0.049) + 15))
              .toInt(),
      'shipping_total': shippingCost.toString(),
      'delivery_total': (shippingCost * 0.80).toString(),
      'zerdaly_total': (shippingCost * 0.20).toString(),
      'total': (productViewData["price"] + shippingCost).toString(),
      'business_shipping': localShipping ? 0.toString() : 1.toString(),
      'card_number': numberSplit,
      'card_month': month,
      'card_year': year,
      'card_cvc': cardCVV.text
    });

    final response = await user.placeOrder(data, auth);

    if (response[0] == "400") {
      if (response[2] == "Your card number is incorrect.") {
        errorMessage("El número de la tarjeta es incorrecto.");
        paymentStatus = false;
      } else if (response[2] == "Your card's expiration year is invalid.") {
        errorMessage("Tu tarjeta esta vencida.");
        paymentStatus = false;
      } else if (response[2] == "Your card's expiration month is invalid.") {
        errorMessage("El mes de la tarjeta es incorrecto.");
        paymentStatus = false;
      } else if (response[2] == "Your card was declined.") {
        errorMessage("Tu tarjeta fue rechaza.");
        paymentStatus = false;
      } else {
        errorMessage("Intentalo otra vez.");
      }
    } else if (response[0] == 200) {
      paymentStatus = false;
      pages = 10;
    } else {
      errorMessage("Intentalo otra vez.");
      paymentStatus = false;
    }
    setState(() {});
  }

  Widget thanksForBuying() {
    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  HexColor("#ff5757"),
                  HexColor("#ff9052"),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: MediaQuery.of(context).size.width * 0.14,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                Text(
                  "Gracias por comprar en ",
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                ),
                Text(
                  "Zerdaly",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      color: Colors.white,
                      fontFamily: "Pacifico"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                Text(
                  "En unos momentos el vendedor\nrecibirá tu pedido para empezar\nel proceso de envío.",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.33,
                    height: MediaQuery.of(context).size.height * 0.06,
                    color: HexColor("#ffffff"),
                    child: Center(
                      child: Text(
                        "Volver",
                        style: TextStyle(
                            color: HexColor("#ff5757"),
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                            fontFamily: 'Kanit'),
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      locationDetails = null;
                      chosenDirection = null;
                      paymentStatus = false;
                      productViewData = null;
                      businessDetails = null;
                      shippingCost = 0;
                      pages = 0;
                    });
                  },
                )
              ],
            )));
  }

  Widget profile() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  HexColor("#ff5757"),
                  HexColor("#ff9052"),
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      "Perfil",
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontSize: MediaQuery.of(context).size.height * 0.03),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1),
                ),
                userInfo != null
                    ? userInfo["image"] == null
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.23,
                            height: MediaQuery.of(context).size.width * 0.23,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: HexColor("#ff9052"),
                                size: MediaQuery.of(context).size.width * 0.12,
                              ),
                            ),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.23,
                            height: MediaQuery.of(context).size.width * 0.23,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                    image: NetworkImage(
                                        userUrl + userInfo["image"]))),
                          )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                Center(
                  child: Text(
                    userInfo["name"] + " " + userInfo["lastname"],
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Kanit',
                        fontSize: MediaQuery.of(context).size.height * 0.02),
                  ),
                ),
                Center(
                  child: Text(
                    userInfo["email"],
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Kanit',
                        fontSize: MediaQuery.of(context).size.height * 0.015),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: <Widget>[
                            Text("Editar Perfil",
                                style: TextStyle(
                                    color: HexColor("#ff9052"),
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.025)),
                            Spacer(),
                            Icon(
                              Icons.edit,
                              color: HexColor("#ff9052"),
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                userName.text = userInfo["name"];
                userLastname.text = userInfo["lastname"];
                userPhone.text = userInfo["phone"];
                userEmail.text = userInfo["email"];

                pages = 13;

              });
            },
          ),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: <Widget>[
                            Text("Ubicaciones",
                                style: TextStyle(
                                    color: HexColor("#ff9052"),
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.025)),
                            Spacer(),
                            Icon(
                              Icons.add_location,
                              color: HexColor("#ff9052"),
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              getLocation();
            },
          ),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: <Widget>[
                            Text("Cerrar sesión",
                                style: TextStyle(
                                    color: HexColor("#ff9052"),
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.025)),
                            Spacer(),
                            Icon(
                              Icons.exit_to_app,
                              color: HexColor("#ff9052"),
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              final id = await token.queryAllRows();
              await token.delete(id[0]['id']);
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MySplashScreen()));
            },
          ),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: <Widget>[
                            Text("Términos y Condiciones",
                                style: TextStyle(
                                    color: HexColor("#ff9052"),
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.025)),
                            Spacer(),
                            Icon(
                              Icons.info,
                              color: HexColor("#ff9052"),
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              print("Terms and Conditions");
            },
          ),
        ],
      ),
    );
  }

  //update user image, info, etc.
  TextEditingController userName = new TextEditingController();
  TextEditingController userLastname = new TextEditingController();
  TextEditingController userEmail = new TextEditingController();
  TextEditingController userPhone = new TextEditingController();
  File userImg;

  Widget updateProfile() {
    return Scaffold(
      key: _scaffoldKey,
      
      body: ListView(
      children: <Widget>[
        Container(
          color: Color.fromRGBO(255, 144, 82, 1),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
                    child: Text(
                      "Editar cuenta",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10, top: 10, bottom: 20),
                      child: Text(
                        "Guardar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Kanit',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    onTap: () {
                      if (userName.text.length < 6) {
                        errorMessage("Tu nombre debe tener la menos 6 letras.");
                      }else if(userLastname.text.length < 6) {
                        errorMessage("Tu apellido debe tener la menos 6 letras.");
                      } else {
                        saveProfileChanges();
                      }
                    },
                  ),
                ],
              ),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.height / 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: userImg == null
                        ? userInfo["image"] != null
                            ? Container(
                                margin: EdgeInsets.only(left: 6, right: 6),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userUrl + userInfo["image"]))),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    GestureDetector(
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                17,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[600]),
                                            child: Icon(Icons.add_a_photo,
                                                color: Colors.white),
                                          ),
                                        ),
                                        onTap: () {
                                          getProfilePicture();
                                        })
                                  ],
                                ),
                              )
                            : Container(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Center(
                                      child: Icon(Icons.store,
                                          size: 35,
                                          color:
                                              Color.fromRGBO(255, 144, 82, 1)),
                                    ),
                                    GestureDetector(
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                17,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[600]),
                                            child: Icon(Icons.add_a_photo,
                                                color: Colors.white),
                                          ),
                                        ),
                                        onTap: () {
                                          getProfilePicture();
                                        })
                                  ],
                                ),
                              )
                        : Container(
                            margin: EdgeInsets.only(left: 7, right: 7),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(userImg),
                                )),
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                GestureDetector(
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                9,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                17,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[600]),
                                        child: Icon(Icons.add_a_photo,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onTap: () {
                                      getProfilePicture();
                                    })
                              ],
                            ))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Nombre',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: userName,
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                'Apellido',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: userLastname,
                decoration: InputDecoration(
                  hintText: 'Apellido',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                'Email',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: userEmail,
                decoration: InputDecoration(
                  hintText: 'Tu email',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                'Número de teléfono',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: userPhone,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: '8095394444',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                  counterText: "",
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }

  getProfilePicture() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        userImg = img;
      });
    } else {
      errorMessage("No se ha seleccionado ninguna foto.");
    }
  }

  saveProfileChanges() async {
    final auth = await token.queryAllRows();

    if (userImg != null) {
      await CompressImage.compress(imageSrc: userImg.path, desiredQuality: 85);

      String businessImgBs64 = base64Encode(userImg.readAsBytesSync());
      final response =
          await user.uploadUserImage(businessImgBs64, auth[0]["Auth"]);

      if (response[0] == 200) {
        if (userEmail.text == userInfo["email"]) {
          updateBusiness(
              json.encode({
                'name': userName.text,
                'lastname': userLastname.text,
                'phone': userPhone.text,
                'image': response[2],
              }),
              auth[0]["Auth"]);
        } else {
          updateBusiness(
              json.encode({
                'name': userName.text,
                'lastname': userLastname.text,
                'phone': userPhone.text,
                'image': response[2],
                'email': userEmail.text
              }),
              auth[0]["Auth"]);
        }
      } else {
        errorMessage("Ha ocurrido un error, Intentalo otra vez.");
      }
    } else {
      if (userEmail.text == userInfo["email"]) {
        updateBusiness(
            json.encode({
              'name': userName.text,
              'lastname': userLastname.text,
              'phone': userPhone.text,
            }),
            auth[0]["Auth"]);
      } else {
        updateBusiness(
            json.encode({
              'name': userName.text,
              'lastname': userLastname.text,
              'phone': userPhone.text,
              'email': userEmail.text
            }),
            auth[0]["Auth"]);
      }
    }
  }

  updateBusiness(var data, String auth) async {
    final result = await user.update(data, auth);

    if (result[0] == "200") {
      imageCache.clear();
      getUserInfo();
      successMessage("Se ha editado correctamente.");
      setState(() {});
    } else if (result[0] == 404) {
      if (result[2]["email"] != null) {
        if (result[2]["email"][0] ==
            "The email must be a valid email address.") {
          errorMessage("Utiliza un email valido.");
        } else if ((result[2]["email"][0] ==
            "The email has already been taken.")) {
          errorMessage("Este email ya esta en uso.");
        }
      } else if (result[2]["lastname"] != null) {
        errorMessage("El apellido solo puede tener letras.");
      } else if (result[2]["name"] != null) {
        errorMessage("El nombre solo puede tener letras.");
      } else {
        errorMessage("Ha ocurrido error, Intentalo de nuevo.");
      }
    } else {
      errorMessage("Ha ocurrido error, Intentalo de nuevo.");
    }
  }

  var locationsInfo;

  getLocation() async {
    setState(() {
      locationsInfo = null;
      pages = 3;
    });
    final auth = await token.queryAllRows();
    final response = await user.getLocations(auth[0]["Auth"]);

    setState(() {
      locationsInfo = response[2];
    });
  }

  Widget locations() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 5),
              ),
              Text("Ubicaciones",
                  style: TextStyle(
                      color: HexColor("#ff9052"),
                      fontFamily: 'Kanit',
                      fontSize: MediaQuery.of(context).size.height * 0.025)),
              Spacer(),
              GestureDetector(
                child: Icon(
                  Icons.add_location,
                  color: HexColor("#ff9052"),
                  size: MediaQuery.of(context).size.height * 0.04,
                ),
                onTap: () {
                  getUserLocation();
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
              )
            ],
          ),
          Divider(),
          locationsInfo != null
              ? locationsInfo.length == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Da click a ",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Kanit',
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02)),
                        Icon(
                          Icons.add_location,
                          color: HexColor("#ff9052"),
                          size: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(" para agregar una ubicación.",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Kanit',
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02)),
                      ],
                    )
                  : Container()
              : Container(),
          ListView.builder(
            itemCount: locationsInfo != null ? locationsInfo.length : 0,
            shrinkWrap: true,
            itemBuilder: (ctx, i) {
              return Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.12,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.92,
                              child: Row(
                                children: <Widget>[
                                  Text(locationsInfo[i]["city"],
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontFamily: 'Kanit',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02)),
                                  Spacer(),
                                  GestureDetector(
                                    child: Icon(Icons.edit,
                                        color: HexColor("#ff9052"),
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.03),
                                    onTap: () {
                                      var latlong = new LatLng(
                                          locationsInfo[i]["latitude"],
                                          locationsInfo[i]["longitude"]);
                                      updateUserLocation(
                                          latlong,
                                          locationsInfo[i]["id"],
                                          locationsInfo[i]["city"],
                                          locationsInfo[i]["description"]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.92,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Detalles",
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontFamily: 'Kanit',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.015)),
                                  Text(
                                      locationsInfo[i]["description"] == null
                                          ? " "
                                          : locationsInfo[i]["description"]
                                              .toString(),
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontFamily: 'Kanit',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.015))
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Completer<GoogleMapController> _controller = Completer();
  var userLocation;
  var location = new Location();

  getUserLocation() async {
    setState(() {
      userLocation = null;
      locationDetails.text = "";
      city = null;
    });
    final tmpLocation = await location.getLocation();

    setState(() {
      userLocation = tmpLocation;
      pages = 4;
    });
  }

  updateUserLocation(
      var location, int id, String locationCity, String details) async {
    setState(() {
      userLocation = location;
      locationDetails.text = details;
      city = locationCity;
      currentLocationId = id;
      pages = 5;
    });
  }

  String city;
  TextEditingController locationDetails = new TextEditingController();

  Widget newLocation() {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              child: GoogleMap(
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  if (_controller == null) {
                    _controller.complete(controller);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(userLocation.latitude, userLocation.longitude),
                  zoom: 16.0,
                ),
                markers: Set<Marker>.of(<Marker>[
                  Marker(
                    markerId: MarkerId("1"),
                    position:
                        LatLng(userLocation.latitude, userLocation.longitude),
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: const InfoWindow(
                      title: 'Usted está aquí',
                    ),
                  ),
                ]),
                onCameraMove: (pos) {
                  double lat = pos.target.latitude;
                  double long = pos.target.longitude;

                  setState(() {
                    userLocation = LatLng(lat, long);
                  });
                },
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Lleva el marcador a donde quieres que te llegue el pedido.",
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      color: Colors.grey[600],
                      fontSize: MediaQuery.of(context).size.width * 0.03),
                ),
                DropdownButton<String>(
                  items: <String>[
                    'Santo Domingo',
                    'Santiago',
                    'San Pedro de Macoris',
                    'La Altagracia',
                    'La Romana',
                    'La Vega',
                    'Puerto Plata'
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(
                        value,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                            fontFamily: "Kanit",
                            color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      city = value;
                    });
                  },
                  hint: Text(city != null ? city : "Elige una ciudad"),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontFamily: "Kanit",
                  ),
                ),
                TextField(
                  controller: locationDetails,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Detalles de la ubicación',
                    hintStyle: TextStyle(
                      fontFamily: 'Kanit',
                      color: Colors.grey[600],
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () => setState(() {
                  saveLocation();
                }),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.done,
                  size: 36.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget updateLocation() {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              child: GoogleMap(
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  if (_controller == null) {
                    _controller.complete(controller);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(userLocation.latitude, userLocation.longitude),
                  zoom: 16.0,
                ),
                markers: Set<Marker>.of(<Marker>[
                  Marker(
                    markerId: MarkerId("1"),
                    position:
                        LatLng(userLocation.latitude, userLocation.longitude),
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: const InfoWindow(
                      title: 'Usted está aquí',
                    ),
                  ),
                ]),
                onCameraMove: (pos) {
                  double lat = pos.target.latitude;
                  double long = pos.target.longitude;

                  setState(() {
                    userLocation = LatLng(lat, long);
                  });
                },
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Lleva el marcador a donde quieres que te llegue el pedido.",
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      color: Colors.grey[600],
                      fontSize: MediaQuery.of(context).size.width * 0.03),
                ),
                DropdownButton<String>(
                  items: <String>[
                    'Santo Domingo',
                    'Santiago',
                    'San Pedro de Macoris',
                    'La Altagracia',
                    'La Romana',
                    'La Vega',
                    'Puerto Plata'
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(
                        value,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                            fontFamily: "Kanit",
                            color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      city = value;
                    });
                  },
                  hint: Text(city != null ? city : "Elige una ciudad"),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontFamily: "Kanit",
                  ),
                ),
                TextField(
                  controller: locationDetails,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Detalles de la ubicación',
                    hintStyle: TextStyle(
                      fontFamily: 'Kanit',
                      color: Colors.grey[600],
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () => setState(() {
                  updateCurrentLocation();
                }),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.done,
                  size: 36.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  saveLocation() {
    if (locationDetails.text.isEmpty || city == null || userLocation == null) {
      errorMessage("Por favor completa todos los campos.");
    } else if (locationDetails.text.length < 6) {
      errorMessage("El detalle debe tener por lo menos 6 letras.");
    } else {
      var data = json.encode({
        'city': city,
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'description': locationDetails.text.toString(),
      });

      saveNewLocation(data);
    }
  }

  int currentLocationId = 0;
  updateCurrentLocation() {
    if (locationDetails.text.isEmpty || city == null || userLocation == null) {
      errorMessage("Por favor completa todos los campos.");
    } else if (locationDetails.text.length < 6) {
      errorMessage("El detalle debe tener por lo menos 6 letras.");
    } else {
      var data = json.encode({
        'id': currentLocationId,
        'city': city,
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'description': locationDetails.text.toString(),
      });

      upCurrentLocation(data);
    }
  }

  saveNewLocation(var data) async {
    final auth = await token.queryAllRows();
    final response = await user.newLocation(data, auth[0]["Auth"]);
    if (response[0] == 200) {
      getLocation();
    }
  }

  upCurrentLocation(var data) async {
    final auth = await token.queryAllRows();
    final response = await user.updateLocation(data, auth[0]["Auth"]);
    if (response[0] == 200) {
      getLocation();
    }
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

  Widget categorySearch() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10, top: 10, right: 10),
            child: Row(
              children: <Widget>[
                Text(
                  categorySearchId == 1
                      ? "Accesorios"
                      : categorySearchId == 2
                          ? "Belleza"
                          : categorySearchId == 3 ? "Comida" : "Vestimentas",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: HexColor("#ff9052"),
                      fontFamily: "Kanit"),
                ),
                Spacer(),
                Icon(
                  categorySearchId == 1
                      ? Icons.headset
                      : categorySearchId == 2
                          ? Icons.color_lens
                          : categorySearchId == 3
                              ? Icons.fastfood
                              : Icons.accessibility,
                  color: HexColor("#ff9052"),
                ),
              ],
            ),
          ),
          Divider(),
          categorySearchData != null
              ? categorySearchData[2].length == 0
                  ? Center(
                      child: Text("Aún no hay disponible.",
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            color: Colors.grey[600],
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                          )),
                    )
                  : Container()
              : Center(
                  child: CircularProgressIndicator(),
                ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: categorySearchData[2] != null
                    ? categorySearchData[2].length
                    : 0,
                itemBuilder: (BuildContext context, int i) => GestureDetector(
                  child: Card(
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.50,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(productUrl +
                                        categorySearchData[2][i]["image"]
                                            .toString()))),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  color: Colors.white70,
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Row(
                                      children: <Widget>[
                                        Text(categorySearchData[2][i]["name"],
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04,
                                                fontFamily: "Kanit")),
                                        Spacer(),
                                        Text(
                                            "\$" +
                                                categorySearchData[2][i]
                                                        ["price"]
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04,
                                                fontFamily: "Kanit")),
                                      ],
                                    ),
                                  )),
                            ))
                      ],
                    )),
                  ),
                  onTap: () {
                    getBusiness(categorySearchData[2][i]["business_id"]);
                    getProductLike(categorySearchData[2][i]["id"]);
                    setState(() {
                      productViewData = categorySearchData[2][i];
                      pages = 1;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  var categorySearchData;
  int categorySearchId = 0;
  getCategory(int id, String token) async {
    setState(() {
      categorySearchData = null;
      categorySearchId = id;
    });
    final result = await user.getProductsByCategory(token, id);

    setState(() {
      categorySearchData = result;
      pages = 6;
    });
  }

  userSearchKey(String keyWord) async {
    setState(() {
      pages = 7;
      searchResultBusiness = null;
      searchResultProducts = null;
    });

    final auth = await token.queryAllRows();
    final response = await user.search(auth[0]["Auth"], keyWord);

    print(response[2]);

    setState(() {
      searchResultProducts = response[2];
      searchResultBusiness = response[3];
    });
  }

  var searchResultProducts, searchResultBusiness;
  searchPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10, top: 10, right: 10),
            child: Text(
              'Resultado de: "' + searchKey.text + '"',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: HexColor("#ff9052"),
                  fontFamily: "Kanit"),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.33,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HexColor("#ff9052"),
                    HexColor("#ff5757"),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Negocios",
                      style: TextStyle(
                          fontFamily: 'Kanit',
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.04)),
                  searchResultBusiness != null
                      ? searchResultBusiness.length > 0
                          ? SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    child: ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: searchResultBusiness != null
                                          ? searchResultBusiness.length
                                          : 0,
                                      itemBuilder:
                                          (BuildContext context, int i) =>
                                              GestureDetector(
                                        child: Card(
                                          child: Center(
                                              child: Column(
                                            children: <Widget>[
                                              searchResultBusiness != null
                                                  ? searchResultBusiness[i]
                                                              ["image"] !=
                                                          null
                                                      ? Container(
                                                          width:
                                                              MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.44,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.237,
                                                          decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image: NetworkImage(businessUrl +
                                                                      searchResultBusiness[i]
                                                                              ["image"]
                                                                          .toString()))),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomLeft,
                                                            child: Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.05,
                                                                color: Colors
                                                                    .white70,
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              1),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          searchResultBusiness[i]
                                                                              [
                                                                              "business_name"],
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontSize: MediaQuery.of(context).size.width * 0.03,
                                                                              fontFamily: "Kanit")),
                                                                    ],
                                                                  ),
                                                                )),
                                                          ))
                                                      : Container(
                                                          width: MediaQuery.of(context).size.width * 0.44,
                                                          height: MediaQuery.of(context).size.height * 0.237,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              Center(
                                                                child: Icon(
                                                                  Icons.store,
                                                                  color: HexColor(
                                                                      "#ff9052"),
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.10,
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .bottomLeft,
                                                                child:
                                                                    Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.05,
                                                                        color: Colors
                                                                            .white70,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(1),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Text(searchResultBusiness[i]["business_name"], maxLines: 1, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, fontFamily: "Kanit")),
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            ],
                                                          ))
                                                  : CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                            ],
                                          )),
                                        ),
                                        onTap: () {
                                          getBusiness(
                                              searchResultBusiness[i]["id"]);
                                          setState(() {
                                            pages = 8;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Text("No se encontró nada.",
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035,
                                  )),
                            )
                      : Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 10),
            child: Text("Productos",
                style: TextStyle(
                    fontFamily: 'Kanit',
                    color: HexColor("#ff9052"),
                    fontSize: MediaQuery.of(context).size.width * 0.04)),
          ),
          searchResultProducts != null
              ? searchResultProducts.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: searchResultProducts != null
                              ? searchResultProducts.length
                              : 0,
                          itemBuilder: (BuildContext context, int i) =>
                              GestureDetector(
                            child: Card(
                              child: Center(
                                  child: Column(
                                children: <Widget>[
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.50,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(productUrl +
                                                  searchResultProducts[i]
                                                          ["image"]
                                                      .toString()))),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            color: Colors.white70,
                                            child: Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                      searchResultProducts[i]
                                                          ["name"],
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04,
                                                          fontFamily: "Kanit")),
                                                  Spacer(),
                                                  Text(
                                                      "\$" +
                                                          searchResultProducts[
                                                                  i]["price"]
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04,
                                                          fontFamily: "Kanit")),
                                                ],
                                              ),
                                            )),
                                      ))
                                ],
                              )),
                            ),
                            onTap: () {
                              getBusiness(
                                  searchResultProducts[i]["business_id"]);
                              getProductLike(searchResultProducts[i]["id"]);
                              setState(() {
                                productViewData = searchResultProducts[i];
                                pages = 1;
                              });
                            },
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text("No se encontró nada.",
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            color: Colors.grey[600],
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                          )),
                    )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }

  Widget businessPage() {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Zerdaly",
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                color: Colors.white,
                fontFamily: "Pacifico"),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.23,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    HexColor("#ff5757"),
                    HexColor("#ff9052"),
                  ],
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 5),
                    child: businessDetails != null
                        ? businessDetails[0]["image"] != null
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height:
                                    MediaQuery.of(context).size.width * 0.22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(businessUrl +
                                            businessDetails[0]["image"]))),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height:
                                    MediaQuery.of(context).size.width * 0.22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.store,
                                    color: HexColor("#ff9052"),
                                    size: MediaQuery.of(context).size.width *
                                        0.10,
                                  ),
                                ),
                              )
                        : Container(),
                  ),
                  Text(
                      businessDetails != null
                          ? businessDetails[0]["business_name"]
                          : "",
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      )),
                  Text(
                      businessDetails != null
                          ? businessProducts.length.toString() + " productos"
                          : "",
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      )),
                ],
              ),
            ),
            businessProducts != null
                ? businessProducts.length > 0
                    ? Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: SizedBox(
                          child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: businessProducts != null
                                ? businessProducts.length
                                : 0,
                            itemBuilder: (BuildContext context, int i) =>
                                GestureDetector(
                              child: Card(
                                child: Center(
                                    child: Column(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.50,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(productUrl +
                                                    businessProducts[i]["image"]
                                                        .toString()))),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
                                              color: Colors.white70,
                                              child: Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        businessProducts[i]
                                                            ["name"],
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.04,
                                                            fontFamily:
                                                                "Kanit")),
                                                    Spacer(),
                                                    Text(
                                                        "\$" +
                                                            businessProducts[i]
                                                                    ["price"]
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.04,
                                                            fontFamily:
                                                                "Kanit")),
                                                  ],
                                                ),
                                              )),
                                        ))
                                  ],
                                )),
                              ),
                              onTap: () {
                                getProductLike(businessProducts[i]["id"]);
                                setState(() {
                                  productViewData = businessProducts[i];
                                  pages = 1;
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text("No se encontró nada.",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              color: Colors.grey[600],
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                            )),
                      )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ));
  }

  Widget productsBought() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Text(
              "Pedidos",
              maxLines: 1,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Kanit',
                  fontSize: MediaQuery.of(context).size.height * 0.02),
            ),
          ),
          Divider(),
          Container(
            child: Row(
              children: <Widget>[
                Spacer(),
                Text(
                  'En camino ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: MediaQuery.of(context).size.width * 0.02,
                  decoration:
                      BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                Spacer(),
                Text(
                  'Enviado ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: MediaQuery.of(context).size.width * 0.02,
                  decoration: BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
                Spacer(),
                Text(
                  'Completado ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                Spacer(),
              ],
            ),
          ),
          orders != null
              ? orders.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Center(
                        child: Text(
                          "Aún no has hecho un pedido.",
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Kanit',
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                      ))
                  : Container()
              : Center(child: CircularProgressIndicator()),
          ListView.builder(
            shrinkWrap: true,
            itemCount: orders != null ? orders.length : 0,
            itemBuilder: (ctx, i) {
              final orderData = orders[i];
              final orderProducts = json.decode(orderData["products_id"]);
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(ctx).size.width / 5,
                            height: MediaQuery.of(ctx).size.width / 5,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(productUrl +
                                        orderProducts[0]["image"]))),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Container(
                              width: MediaQuery.of(ctx).size.width / 1.5,
                              //  height: MediaQuery.of(ctx).size.width / 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                          orderProducts.length == 1
                                              ? orderProducts[0]["name"]
                                              : orderProducts[0]["name"] +
                                                  " y otros...",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15,
                                            fontFamily: 'Kanit',
                                          )),
                                      Spacer(),
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                            color: orderData["delivery_id"] ==
                                                    null
                                                ? Colors.red
                                                : orderData["shipping_status"] ==
                                                        4
                                                    ? Colors.green
                                                    : Colors.orange,
                                            shape: BoxShape.circle),
                                      ),
                                    ],
                                  ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(top: 1),
                                  // ),
                                  Row(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Total",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    31,
                                                fontFamily: 'Kanit',
                                              )),
                                          Text(
                                              orderData["products_total"]
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    31,
                                                fontFamily: 'Kanit',
                                              )),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Cant.",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    31,
                                                fontFamily: 'Kanit',
                                              )),
                                          Text(orderProducts.length.toString(),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    31,
                                                fontFamily: 'Kanit',
                                              )),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Detalles",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    31,
                                                fontFamily: 'Kanit',
                                              )),
                                          GestureDetector(
                                            child: Text("Ver más",
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          31,
                                                  fontFamily: 'Kanit',
                                                )),
                                            onTap: () {
                                              setState(() {
                                                productViewData = orderProducts;
                                                orderDetails = orderData;
                                                deliveryDetails = null;
                                                pages = 12;
                                              });
                                              getBusiness(
                                                  orderData["business_id"]);

                                              if (orderData["delivery_id"] !=
                                                  null) {
                                                getDelivery(
                                                    orderData["delivery_id"]);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                    ],
                                  )
                                ],
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  var productsBoughtDetails, orderDetails, deliveryDetails;

  Widget productBougthDetails() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zerdaly",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
              fontFamily: "Pacifico"),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: Text(
              "Negocio",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Card(
                child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Nombre",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                              businessDetails == null
                                  ? " "
                                  : businessDetails[0]["business_name"],
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                fontFamily: 'Kanit',
                              )),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Teléfono",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                              businessDetails == null
                                  ? " "
                                  : businessDetails[0]["phone"],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                fontFamily: 'Kanit',
                              )),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Fecha",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w800),
                          ),
                          Text(userDateOfPurchase(orderDetails["created_at"]),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                fontFamily: 'Kanit',
                              )),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: Text(
              productViewData.length == 1 ? "Producto" : "Productos",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w800),
            ),
          ),
          ListView.builder(
            itemCount: productViewData.length,
            shrinkWrap: true,
            itemBuilder: (ctx, i) {
              final productDetails = productViewData[i];

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(ctx).size.width / 7,
                            height: MediaQuery.of(ctx).size.width / 7,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        productUrl + productDetails["image"]))),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Container(
                              width: MediaQuery.of(ctx).size.width / 1.3,
                              height: MediaQuery.of(ctx).size.width / 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Nombre",
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: 'Kanit',
                                                  fontWeight: FontWeight.w800)),
                                          Text(
                                              productDetails["name"].toString(),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Kanit',
                                              )),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Cant.",
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: 'Kanit',
                                                  fontWeight: FontWeight.w800)),
                                          Text(1.toString(),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Kanit',
                                              )),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Precio",
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: 'Kanit',
                                                  fontWeight: FontWeight.w800)),
                                          Text(
                                              "\$" +
                                                  productDetails["price"]
                                                      .toString(),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Kanit',
                                              ))
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: Text(
              "Envío",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w800),
            ),
          ),
          orderDetails["business_shipping"] == 1
              ? Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                            child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Precio",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                          orderDetails == null
                                              ? " "
                                              : "\$" +
                                                  orderDetails["shipping_total"]
                                                      .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            fontFamily: 'Kanit',
                                          )),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Emisor",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                          businessDetails == null
                                              ? " "
                                              : businessDetails[0]
                                                  ["business_name"],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            fontFamily: 'Kanit',
                                          )),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Estado",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                          orderDetails["shipping_status"] == 4
                                              ? "Enviado"
                                              : "No enviado",
                                          style: TextStyle(
                                            color: orderDetails[
                                                        "shipping_status"] ==
                                                    0
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            fontFamily: 'Kanit',
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ))
              : Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Nombre",
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                    deliveryDetails == null
                                        ? "No disponible"
                                        : deliveryDetails[0]["name"] +
                                            " " +
                                            deliveryDetails[0]["lastname"],
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      fontFamily: 'Kanit',
                                    )),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Teléfono",
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                    deliveryDetails == null
                                        ? "No Disponible"
                                        : deliveryDetails[0]["phone"],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      fontFamily: 'Kanit',
                                    )),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Estado",
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                    orderDetails["shipping_status"] == 0
                                        ? "En proceso"
                                        : orderDetails["shipping_status"] < 4
                                            ? "En camino"
                                            : "Completado",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      fontFamily: 'Kanit',
                                    )),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
                ),
        ],
      ),
    );
  }

  String userDateOfPurchase(String date) {
    final dateSplit = date.split("-");
    final daySlit = dateSplit[2].split(" ");

    return daySlit[0] + "/" + dateSplit[1] + "/" + dateSplit[0];
  }

  getDelivery(int id) async {
    final auth = await token.queryAllRows();

    final response = await user.getDelivery(id, auth[0]["Auth"]);

    setState(() {
      deliveryDetails = response[2];
    });
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
