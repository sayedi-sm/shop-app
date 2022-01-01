import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/carts.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/carts_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import 'screens/auth_screen.dart';
import 'screens/edit_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(),
          // Do not get the token in Products constructor,
          // instead call methods inside it, as say official docs
          update: (ctx, auth, products) {
            products!.authToken = auth.token;
            return products..userId = auth.userId;
          },
        ),
        ChangeNotifierProvider(create: (_) => Carts()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (_, auth, orders) {
            orders!.authToken = auth.token;
            return orders..userId = auth.userId;
          },
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        return MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: "Lato",
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),
          // The following line is not working, instead use the 'home' parameter
          // initialRoute: auth.isAuth ? ProductsOverviewScreen.ID : AuthScreen.ID,
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductsOverviewScreen.ID: (_) => ProductsOverviewScreen(),
            ProductDetailScreen.ID: (_) => ProductDetailScreen(),
            CartScreen.ID: (_) => CartScreen(),
            OrdersScreen.ID: (_) => OrdersScreen(),
            UserProductsScreen.ID: (_) => UserProductsScreen(),
            EditProductScreen.ID: (_) => EditProductScreen(),
            AuthScreen.ID: (_) => AuthScreen(),
          },
        );
      }),
    );
  }
}
