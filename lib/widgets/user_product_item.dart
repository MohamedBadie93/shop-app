import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/product.dart';
import 'package:shop_app_3/providers/products.dart';
import 'package:shop_app_3/screens/edit_products_screen.dart';

class UserProductItem extends StatelessWidget {
  Product product;
  UserProductItem(this.product);
  @override
  Widget build(BuildContext context) {
    final scaffoldMessen = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: product.id);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(product.id);
                } catch (error) {
                  scaffoldMessen.showSnackBar(
                    SnackBar(
                      content: Text(error.toString()),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
