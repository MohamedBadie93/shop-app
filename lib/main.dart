import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/auth.dart';
import 'package:shop_app_3/providers/cart.dart';
import 'package:shop_app_3/providers/orders.dart';
import 'package:shop_app_3/providers/products.dart';
import 'package:shop_app_3/screens/auth_screen.dart';
import 'package:shop_app_3/screens/cart_screen.dart';
import 'package:shop_app_3/screens/check_auth_screen.dart';
import 'package:shop_app_3/screens/edit_products_screen.dart';
import 'package:shop_app_3/screens/orders_screen.dart';
import 'package:shop_app_3/screens/product_details_screen.dart';
import 'package:shop_app_3/screens/products_overview_screen.dart';
import 'package:shop_app_3/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        //ChangeNotifierProvider(create: (ctx) => Products()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(null, null, []),
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.allProducts),
        ),

        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(null, null, []),
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orderItems),
        )
        //ChangeNotifierProvider(create: (ctx) => Orders()),
      ],
      child: Consumer<Auth>(
          builder: (ctx, authProvider, _) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'shop_app_3',
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.deepOrange,
                  fontFamily: 'Lato',
                ),
                home: authProvider.isAuthenticated
                    ? ProductsOverviewScreen()
                    : FutureBuilder(
                        future: authProvider.tryAutoLogin(),
                        builder: (ctx, snapShot) =>
                            snapShot.connectionState == ConnectionState.waiting
                                ? Center(child: Text("Splaaaash...."))
                                : AuthScreen(),
                      ),
                routes: {
                  ProductsOverviewScreen.routeName: (ctx) =>
                      ProductsOverviewScreen(),
                  ProductDetailsScreen.routeName: (ctx) =>
                      ProductDetailsScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  OrdersScreen.routeName: (ctx) => OrdersScreen(),
                  UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                },
              )),
    );
  }
}
