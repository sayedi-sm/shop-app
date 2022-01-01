import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/carts.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/carts_screen.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const String ID = "ProductsOverviewScreen";

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoritesOnly = false;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<Products>(context, listen: false).fetchAndSetProducts().then(
      (_) {
        setState(() {
          _isLoading = false;
        });
      },
    );

    // If listen = true, then use the following code
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("MyShop"),
        actions: [
          PopupMenuButton(
            onSelected: (selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showFavoritesOnly = true;
                } else {
                  _showFavoritesOnly = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FilterOptions.Favorites,
                child: Text("Only Favorites"),
              ),
              PopupMenuItem(
                value: FilterOptions.All,
                child: Text("Show All"),
              ),
            ],
          ),
          Consumer<Carts>(
            builder: (_, cart, widget) => Badge(
              child: widget!,
              value: cart.itemCount.toString(),
              color: Theme.of(context).accentColor,
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                // Navigator.of(context).pushNamed(CartScreen.ID);
                Navigator.of(context).push(
                  CustomRoute(builder: (ctx) => CartScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavoritesOnly),
    );
  }
}
