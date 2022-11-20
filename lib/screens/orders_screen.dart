import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/orders.dart' show Orders;
import 'package:shop_app_3/providers/products.dart';
import 'package:shop_app_3/widgets/main_drawer.dart';
import 'package:shop_app_3/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = '/orders-screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isInit = false;
  var _loadingOrders = false;

  Future<void> _loadOrders(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  // @override
  // void didChangeDependencies() {
  //   if (!_isInit) {
  //     try {
  //       setState(() {
  //         _loadingOrders = true;
  //       });
  //       Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
  //         setState(() {
  //           _loadingOrders = false;
  //         });
  //       });
  //     } catch (error) {
  //       print(error);
  //     }
  //   }
  //   _isInit = true;
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _loadingOrders = true;
      });

      Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
        setState(() {
          _loadingOrders = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orders ordersProvider = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: _loadingOrders
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () {
                return _loadOrders(context);
              },
              child: ListView.builder(
                itemBuilder: (ctx, i) {
                  return OrderItem(order: ordersProvider.orderItems[i]);
                },
                itemCount: ordersProvider.orderItems.length,
              ),
            ),
      drawer: MainDrawer(),
    );
  }
}
