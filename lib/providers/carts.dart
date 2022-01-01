import 'package:flutter/material.dart';

import '../models/cart.dart';

class Carts with ChangeNotifier {
  Map<String, Cart> _items = {};

  Map<String, Cart> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String itemId, String title, double price) {
    if (_items.containsKey(itemId)) {
      _items.update(
        itemId,
        (existingCartItem) => Cart(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        itemId,
        () => Cart(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity == 1) {
        _items.remove(productId);
      } else {
        _items.update(
          productId,
          (oldCart) => Cart(
            id: oldCart.id,
            title: oldCart.title,
            quantity: oldCart.quantity - 1,
            price: oldCart.price,
          ),
        );
      }
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
