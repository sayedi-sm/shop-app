import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/cart.dart';
import 'package:shop_app/models/order.dart';
import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  String? _authToken;
  String? _userId;

  set authToken(String? token) {
    _authToken = token;
  }

  set userId(String? userId) {
    _userId = userId;
  }

  Future<void> fetchAndSetOrders() async {
    var url = Uri.parse(
        "https://shop-app-75188-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken");
    final response = await http.get(url);
    var extractedData = json.decode(response.body);
    if (extractedData == null) {
      return;
    }
    extractedData = extractedData as Map<String, dynamic>;
    _items.clear();
    extractedData.forEach((orderId, orderData) {
      _items.add(Order(
        id: orderId,
        amount: orderData["amount"],
        products: (orderData["products"] as List<dynamic>)
            .map((item) => Cart(
                  id: item["id"],
                  title: item["title"],
                  quantity: item["quantity"],
                  price: item["price"],
                ))
            .toList(),
        dateTime: DateTime.parse(orderData["dateTime"]),
      ));
    });
    _items = _items.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<Cart> cartProducts, double total) async {
    var url = Uri.parse(
        "https://shop-app-75188-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken");
    var timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        "amount": total,
        "dateTime": timeStamp.toIso8601String(),
        "products": cartProducts
            .map((cart) => {
                  "id": cart.id,
                  "title": cart.title,
                  "quantity": cart.quantity,
                  "price": cart.price,
                })
            .toList(),
      }),
    );
    _items.insert(
      0,
      Order(
        id: json.decode(response.body)["name"],
        products: cartProducts,
        amount: total,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
