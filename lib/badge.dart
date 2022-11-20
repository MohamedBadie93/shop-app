import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:shop_app_3/screens/cart_screen.dart';

class Badge extends StatelessWidget {
  final int itemsCount;
  Badge(this.itemsCount);
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
            icon: Icon(Icons.shopping_cart)),
        if (itemsCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(minHeight: 16, minWidth: 16),
              child: Text(
                "${itemsCount}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
