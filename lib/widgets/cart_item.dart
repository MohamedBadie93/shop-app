import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/cart.dart';

class CartItem extends StatelessWidget {
  String id;
  String productId;
  String title;
  double price;
  int quantety;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantety,
  });
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) {
        return showDialog<bool>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text("Are you sure ?"),
                content: Text("You are going to delete this cart item."),
                actions: [
                  TextButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 4,
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: FittedBox(
                child: Text("\$${price}"),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text("Total: \$${(price * quantety).toStringAsFixed(2)}"),
          trailing: Text("${quantety} X"),
        ),
      ),
    );
  }
}
