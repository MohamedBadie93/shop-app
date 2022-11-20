import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/product.dart';
import 'package:shop_app_3/providers/products.dart';
import 'package:shop_app_3/screens/edit_products_screen.dart';
import 'package:shop_app_3/widgets/main_drawer.dart';
import 'package:shop_app_3/widgets/user_product_item.dart';

class UserProductsScreen extends StatefulWidget {
  static const String routeName = '/user-products';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isInit = false;
  var _isLoading = false;

  Future<void> _loadProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
    }).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Products productsProvider = Provider.of<Products>(context);
    List<Product> products = productsProvider.allProducts;
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Products"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _loadProducts(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemBuilder: (ctx, i) {
              return Column(
                children: [
                  UserProductItem(products[i]),
                  Divider(),
                ],
              );
            },
            itemCount: products.length,
          ),
        ),
      ),
      drawer: MainDrawer(),
    );
  }
}
