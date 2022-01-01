import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/cart.dart';
import 'package:shop_app/providers/carts.dart';

class CartItem extends StatelessWidget {
  final Cart cart;
  final String productId;

  CartItem(this.cart, this.productId);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cart.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Carts>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Are you sure?"),
            content: Text("Do you want to remove the item from the cart?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  "No",
                  textAlign: TextAlign.end,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  "Yes",
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      },
      background: Container(
        color: Theme.of(context).errorColor,
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: FittedBox(
                child: Text("\$${cart.price}"),
              ),
            ),
          ),
          title: Text(cart.title),
          subtitle: Text(
              "Total: \$${(cart.price * cart.quantity).toStringAsFixed(2)}"),
          trailing: Text("${cart.quantity}x"),
        ),
      ),
    );
  }
}
