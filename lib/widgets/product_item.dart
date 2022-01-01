import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/carts.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // set the listen to false, so that the entire tree is not re-built
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Carts>(context, listen: false);
    final scaffold = Scaffold.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            ProductDetailScreen.ID,
            arguments: product,
          ),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage("assets/images/placeholder.png"),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // By consumer, we can wrap the part of UI, that needs rendering
            builder: (_, product, __) {
              return IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () async {
                  product.toggleFavorite();
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .updateFavorite(
                      product.id,
                      product.isFavorite,
                    );
                  } catch (error) {
                    product.toggleFavorite();
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Could not add to favorites!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              Scaffold.of(context).removeCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Added a ${product.title} to the cart!",
                  ),
                  action: SnackBarAction(
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                    label: "UNDO",
                  ),
                ),
              );
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
