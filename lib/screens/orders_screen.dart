import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const ID = "OrdersScreen";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // We store the future in a field, so that future is not
  // called again and again upon re-building the widget tree
  late Future _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture =
        Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.hasError) {
              return Center(
                child: Text("An error occurred !"),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orders, child) => ListView.builder(
                  itemCount: orders.items.length,
                  itemBuilder: (ctx, index) {
                    return OrderItem(orders.items[index]);
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}
