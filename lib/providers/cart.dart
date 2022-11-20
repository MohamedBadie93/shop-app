import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantety;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantety,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  /*********** Start Getters *************/

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  int get itemsCount {
    return _cartItems.length;
  }

  double get totalCost {
    double total = 0.0;

    _cartItems.forEach((key, value) {
      total += (value.price * value.quantety);
    });
    return total;
  }

  /*********** End Getters *************/

  /*********** Start Setters *************/

  void addCartItem(String productId, String title, double price) {
    final bool isCartItemExists = _cartItems.containsKey(productId);

    if (isCartItemExists) {
      // Just increase Quantety
      _cartItems.update(
        productId,
        (oldCartItem) => CartItem(
            id: oldCartItem.id,
            title: oldCartItem.title,
            price: oldCartItem.price,
            quantety: oldCartItem.quantety + 1),
      );
    } else {
      _cartItems.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            price: price,
            quantety: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void reduceQtOrRemove(String productId) {
    final CartItem? item = _cartItems[productId];
    if (item != null) {
      if (item.quantety > 1) {
        _cartItems.update(
          productId,
          (oldItem) => CartItem(
            id: oldItem.id,
            title: oldItem.title,
            price: oldItem.price,
            quantety: oldItem.quantety - 1,
          ),
        );
      } else {
        removeItem(productId);
      }
    }
  }

  void clear() {
    _cartItems = {};
    notifyListeners();
  }

  // Never Forgets notifyListeners();
  /*********** End Setters *************/
}
