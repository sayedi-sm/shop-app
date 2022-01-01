import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String productId;
  final String title;
  final String imageUrl;

  UserProductItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(EditProductScreen.ID, arguments: productId),
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .deleteProduct(productId);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Deleting failed!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
