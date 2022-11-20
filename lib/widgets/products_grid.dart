import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/products.dart';
import 'package:shop_app_3/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final showOnlyFavorites;
  ProductsGrid(this.showOnlyFavorites);
  @override
  Widget build(BuildContext context) {
    var productsProvider = Provider.of<Products>(context);
    var products = showOnlyFavorites
        ? productsProvider.favProducts
        : productsProvider.allProducts;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(),
      ),
    );
  }
}
