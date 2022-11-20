import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/badge.dart';
import 'package:shop_app_3/providers/cart.dart';
import 'package:shop_app_3/providers/products.dart';
import 'package:shop_app_3/widgets/main_drawer.dart';
import 'package:shop_app_3/widgets/products_grid.dart';

class ProductsOverviewScreen extends StatefulWidget {
  static const String routeName = '/products-overview-screen';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = false;
  var _loadingProducts = false;

  @override
  void initState() {
    // Future.delayed(Duration.zero)
    //     .then((value) => Provider.of<Products>(context).fetchAndSetProducts());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      try {
        setState(() {
          _loadingProducts = true;
        });
        Provider.of<Products>(context).fetchAndSetProducts().then((_) {
          setState(() {
            _loadingProducts = false;
          });
        });
      } catch (error) {
        print(error);
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop App"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions filterOption) {
              setState(() {
                if (filterOption == FilterOptions.ShowAll) {
                  _showOnlyFavorites = false;
                } else {
                  _showOnlyFavorites = true;
                }
              });
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.ShowAll,
              ),
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.OnlyFavorites,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cartProvider, child) =>
                Badge(cartProvider.itemsCount),
          ),
        ],
      ),
      body: _loadingProducts
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
      drawer: MainDrawer(),
    );
  }
}

enum FilterOptions {
  ShowAll,
  OnlyFavorites,
}
