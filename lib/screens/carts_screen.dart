import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/carts.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const ID = "CartScreen";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Carts>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6!.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return CartItem(
                  cart.items.values.toList()[index],
                  cart.items.keys.toList()[index],
                );
              },
              itemCount: cart.items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Carts cart;

  const OrderButton(this.cart);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount == 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                widget.cart.clear();
              } catch (error) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text("Ooooops!!"),
                    content: Text("Something went wrong"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Okay"),
                      )
                    ],
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
      child: _isLoading ? CircularProgressIndicator() : Text("ORDER NOW"),
    );
  }
}
