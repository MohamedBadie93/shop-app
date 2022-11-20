import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app_3/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.cartItems,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  String? authToken;
  String? userId;
  Orders(this.authToken, this.userId, this._orderItems);
  List<OrderItem> _orderItems = [];

  /*********************** Start Getters ***********************/

  List<OrderItem> get orderItems {
    return [..._orderItems];
  }

  /*********************** End Getters ***********************/

  /*********************** Start Setters ***********************/

  Future<void> addOrder(double amount, List<CartItem> cartItems) async {
    final url = Uri.parse(
        'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com//orders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': amount,
            'cartItems': cartItems.map((cartItem) {
              return {
                'id': cartItem.id,
                'title': cartItem.title,
                'price': cartItem.price,
                'quantety': cartItem.quantety,
              };
            }).toList(),
            'dateTime': timeStamp.toIso8601String(),
          },
        ),
      );
      _orderItems.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: amount,
          cartItems: cartItems,
          dateTime: DateTime.now(),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? extractedOrders =
          json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedOrders == null) {
        return;
      }
      extractedOrders.forEach((orderId, order) {
        loadedOrders.insert(
            0,
            OrderItem(
              id: orderId,
              amount: order['amount'],
              dateTime: DateTime.parse(order['dateTime']),
              cartItems: (order['cartItems'] as List<dynamic>)
                  .map((cartItem) => CartItem(
                      id: cartItem['id'],
                      title: cartItem['title'],
                      price: cartItem['price'],
                      quantety: cartItem['quantety']))
                  .toList(),
            ));
      });
      _orderItems = loadedOrders;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  /*********************** End Setters ***********************/
}
