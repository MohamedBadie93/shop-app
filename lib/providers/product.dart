import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app_3/models/http_exeptions.dart';

class Product with ChangeNotifier {
  String id;
  String title;

  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleIsFavorite(String? authToken, String? userId) async {
    final bool oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final url = Uri.parse(
          'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/userFavorites/${userId}/${id}.json?auth=${authToken}');
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
        throw HttpExptions('couldn\'t change status');
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
      throw error;
    }
  }
}
