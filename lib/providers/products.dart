import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/models/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  String? _authToken;
  String? _userId;

  set authToken(String? authToken) {
    _authToken = authToken;
  }

  set userId(String? userId) {
    _userId = userId;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> favoriteItems() {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final String filterString = filterByUser
        ? 'orderBy="userId"&equalTo="$_userId"'
        : ''; // Use double quotes for filtering keys, single quotes doesn't work
    var url = Uri.parse(
        'https://shop-app-75188-default-rtdb.firebaseio.com/products.json?auth=$_authToken&$filterString');
    _items.clear();
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse(
          "https://shop-app-75188-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken");
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        _items.add(Product(
          id: prodId,
          title: prodData["title"],
          description: prodData["description"],
          price: prodData["price"],
          imageUrl: prodData["imageUrl"],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        "https://shop-app-75188-default-rtdb.firebaseio.com/products.json?auth=$_authToken");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "userId": _userId,
        }),
      );
      Product prod = Product(
        id: json.decode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(prod);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    var url = Uri.parse(
        "https://shop-app-75188-default-rtdb.firebaseio.com/products/${product.id}.json?auth=$_authToken");
    await http.patch(url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        }));
    var productIndex = _items.indexWhere((prod) => product.id == prod.id);
    _items[productIndex] = product;
    notifyListeners();
  }

  Future<void> updateFavorite(String productId, bool favoriteStatus) async {
    var url = Uri.parse(
        "https://shop-app-75188-default-rtdb.firebaseio.com/userFavorites/$_userId/$productId.json?auth=$_authToken");
    final response = await http.put(
      url,
      body: json.encode(favoriteStatus),
    );
    if (response.statusCode >= 400) {
      throw HttpException(("Could not update favorite status"));
    }
  }

  Future<void> deleteProduct(String id) async {
    var url = Uri.parse(
        "https://shop-app-75188-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken");
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    final existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product!");
    }
  }
}
