import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/models/order.dart';

class OrderItem extends StatefulWidget {
  final Order order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? min(widget.order.products.length * 25, 100) + 95 : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          // Use SingleChildScrollView widget, otherwise it will cause pixel overflow with animated containers
          child: Column(
            children: [
              ListTile(
                title: Text("\$${widget.order.amount.toStringAsFixed(2)}"),
                subtitle: Text(
                  DateFormat("dd-MM-yyyy, hh:mm").format(widget.order.dateTime),
                ),
                trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
              if (_expanded)
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  height: _expanded
                      ? min(widget.order.products.length * 25, 100)
                      : 0,
                  child: ListView(
                    children: widget.order.products
                        .map(
                          (product) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${product.quantity} x \$${product.price}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
