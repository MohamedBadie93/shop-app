import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/cart.dart' show Cart;
import 'package:shop_app_3/providers/orders.dart';
import 'package:shop_app_3/widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart-screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final Cart cartProvider = Provider.of<Cart>(context);
    final Orders ordersProvider = Provider.of<Orders>(context, listen: false);
    final cartItems = cartProvider.cartItems;
    return Scaffold(
      appBar: AppBar(
        title: Text("Your cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            elevation: 7,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    "Total :",
                    style: TextStyle(fontSize: 18),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartProvider.totalCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6!.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text("ORDER NOW"),
                    onPressed: cartProvider.itemsCount > 0
                        ? () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await ordersProvider.addOrder(
                                cartProvider.totalCost,
                                cartItems.values.toList(),
                              );
                              cartProvider.clear();
                            } catch (error) {
                              await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title:
                                          Text("Couldn\'t register this order"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Okay"),
                                        )
                                      ],
                                    );
                                  });
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) {
                return CartItem(
                  id: cartItems.values.toList()[i].id,
                  productId: cartItems.keys.toList()[i],
                  title: cartItems.values.toList()[i].title,
                  price: cartItems.values.toList()[i].price,
                  quantety: cartItems.values.toList()[i].quantety,
                );
              },
              itemCount: cartProvider.itemsCount,
            ),
          ),
        ],
      ),
    );
  }
}
