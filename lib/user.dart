import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class User {
  final url = 'https://api.zerdaly.com/api/user/';

  Future<List> login(String email, String pass) async {
    List response = new List(3);
    await http.post(url + 'login', body: {
      'json': json.encode({
        'email': email,
        'password': pass,
      }).toString(),
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result['code'];
      response[1] = result['status'];
      response[2] = result['token'];
    });
    return response;
  }

  Future<List> register(var data) async {
    List response = new List(5);

    await http
        .post(url + "register", body: {'json': json.encode(data)}).then((res) {
      final data = json.decode(res.body);
      response[0] = data["code"];
      response[1] = data["status"];
      response[2] = data["errors"];
      response[3] = data["message"];
      response[4] = data["token"];
    }).catchError((error) {});
    return response;
  }

  Future<List> update(var data, String token) async {
    List response = new List(3);

    await http.put(url + "update", body: {
      'json': data,
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);

      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> uploadUserImage(String img, String token) async {
    List response = new List(3);
    await http.post(url + "upload", body: {
      'json': json.encode({
        'image': img,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["image"];
    }).then((error) {});

    return response;
  }

  Future<List> info(String token) async {
    List response = new List(3);
    await http.post(url + "info",
        headers: {HttpHeaders.authorizationHeader: token}).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["user"];
      response[2] = result["user_orders"];
    }).catchError((error) {});

    return response;
  }

  Future<List> getLocations(String token) async {
    List response = new List(4);
    await http.post(url + "get/locations",
        headers: {HttpHeaders.authorizationHeader: token}).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> newLocation(var data, String token) async {
    List response = new List(3);

    await http.post(url + "new/location", body: {
      'json': data,
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);

      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> updateLocation(var data, String token) async {
    List response = new List(3);

    await http.put(url + "update/location", body: {
      'json': data,
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);

      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> getBusiness(int id, String token) async {
    List response = new List(4);
    await http.post("https://api.zerdaly.com/api/business/getbusiness", body: {
      'json': json.encode({
        'id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["business"];
      response[3] = result["products"];

    }).then((error) {});

    return response;
  }

  Future<List> getProductLike(int id, String token) async {
    List response = new List(4);
    await http.post(url + "get/product/like", body: {
      'json': json.encode({
        'product_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
      response[3] = result["errors"];
    }).then((error) {});

    return response;
  }

  Future<List> likeProduct(int id, String token) async {
    List response = new List(3);
    await http.post(url + "like/product", body: {
      'json': json.encode({
        'product_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> unlikeProduct(int id, String token) async {
    List response = new List(3);
    await http.post(url + "unlike/product", body: {
      'json': json.encode({
        'product_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> getProductsByCategory(String token, int id) async {
    List response = new List(3);
    await http.post(url + "get/products/by/category", body: {
      'json': json.encode({
        'category_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).catchError((error) {});

    return response;
  }

  Future<List> getRandomProducts(String token) async {
    List response = new List(3);
    await http.post(url + "get/random/products",
        headers: {HttpHeaders.authorizationHeader: token}).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).catchError((error) {});

    return response;
  }

  Future<List> search(String token, String word) async {
    List response = new List(4);
    await http.post(url + "search", body: {
      'json': json.encode({
        'key_search': word,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["products"];
      response[3] = result["business"];

    }).catchError((error) {});

    return response;
  }

  
  Future<List> placeOrder(var data, String token) async {
    List response = new List(3);

    await http.post(url + "new/order", body: {
      'json': data,
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);

      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

    Future<List> getDelivery(int id, String token) async {
    List response = new List(3);
    await http.post("https://api.zerdaly.com/api/delivery/getdelivery", body: {
      'json': json.encode({
        'id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

}
