import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = '/product-details-screen';
  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context)!.settings.arguments as String;
    final product = Provider.of<Products>(context, listen: false).findByID(id);
    return Scaffold(
      appBar: AppBar(
        title: Text("${product.title}"),
      ),
      body: Column(
        children: [
          Hero(
            tag: id,
            child: Image.network(
              product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '\$${product.price}',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(
              '${product.description}',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
