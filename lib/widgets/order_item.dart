import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app_3/providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem({required this.order});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded
          ? min(widget.order.cartItems.length * 20 + 110, 200)
          : 100,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text("\$${widget.order.amount.toStringAsFixed(2)}"),
              subtitle:
                  Text(DateFormat('dd/MM/yyyy').format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _isExpanded
                  ? min(widget.order.cartItems.length * 20 + 10, 100)
                  : 0,
              child: ListView(
                children: widget.order.cartItems.map((cartItem) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cartItem.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${cartItem.quantety}X \$${cartItem.price}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
