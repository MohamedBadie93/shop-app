import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/auth.dart';
import 'package:shop_app_3/providers/cart.dart';
import 'package:shop_app_3/providers/product.dart';
import 'package:shop_app_3/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cartProvider = Provider.of<Cart>(context, listen: false);
    final authProvider = Provider.of<Auth>(context, listen: false);

    final scaffoldMessng = ScaffoldMessenger.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
        },
        child: GridTile(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
              // child: Image.network(
              //   product.imageUrl,
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              builder: (ctx, procuct, children) => IconButton(
                icon: product.isFavorite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_outline),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  try {
                    await product.toggleIsFavorite(
                        authProvider.token, authProvider.userId);
                  } catch (error) {
                    scaffoldMessng.showSnackBar(
                        SnackBar(content: Text(error.toString())));
                  }
                },
              ),
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).accentColor,
              onPressed: () {
                cartProvider.addCartItem(
                    product.id, product.title, product.price);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Item Added to cart"),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cartProvider.reduceQtOrRemove(product.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
