import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app_3/models/http_exeptions.dart';

import 'package:shop_app_3/providers/product.dart';

class Products with ChangeNotifier {
  String? authToken;
  String? userId;

  Products(this.authToken, this.userId, this._products);

  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Zoro t-Shirt',
    //   description: 'Zoro t-Shirt - it is pretty Zoro!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.shopify.com/s/files/1/0612/4231/0852/products/luffyxzoro_1.png',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Zoro Katana',
    //   description: 'A nice Katana.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://cdn.shopify.com/s/files/1/0578/4567/8248/products/DSC_6648_1024x.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  /******** Start Getters *********/

  List<Product> get allProducts {
    return [..._products];
  }

  List<Product> get favProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findByID(String productId) {
    return _products.firstWhere((product) => product.id == productId);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorID"&equalTo="${userId}"' : "";
    var url = Uri.parse(
        'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/products.json?auth=$authToken&${filterString}');
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? extractedData =
          json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          "https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken");
      final favoritesResponse = await http.get(url);
      final favoritesData = json.decode(favoritesResponse.body);
      //print(favoritesData);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (productId, product) {
          loadedProducts.add(
            Product(
              id: productId,
              title: product['title'],
              description: product['description'],
              price: product['price'],
              imageUrl: product['imageUrl'],
              isFavorite: favoritesData == null
                  ? false
                  : favoritesData[productId] ?? false,
            ),
          );
        },
      );
      _products = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  /******** End Getters *********/

  /******** Start Setters *********/
  Future<void> addProduct(Product newProduct) async {
    final url = Uri.parse(
        'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'creatorID': userId,
          },
        ),
      );
      Product cacheProduct = Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
      );
      _products.add(cacheProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final productIndex =
        _products.indexWhere((product) => product.id == productId);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken');
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        }),
      );

      _products[productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    final productIndex =
        _products.indexWhere((product) => product.id == productId);

    if (productIndex >= 0) {
      Product? backupProduct = _products[productIndex];
      _products.removeAt(productIndex);
      notifyListeners();

      final url = Uri.parse(
          'https://flutter-shop-app-f01da-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken');
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _products.insert(productIndex, backupProduct);
        notifyListeners();
        throw HttpExptions('Cant delete this item x.');
      }

      backupProduct = null;
    }
  }
  /******** Start Setters *********/

}
