import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const ID = "UserProductsScreen";

  Future<void> _refreshProducts(context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Products"),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.ID),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.hasError) {
              return Center(
                child: Text("An error has occurred"),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (_, productsData, __) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (ctx, index) => UserProductItem(
                        productId: productsData.items[index].id,
                        title: productsData.items[index].title,
                        imageUrl: productsData.items[index].imageUrl,
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
