import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';

import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  //final String id;
  //final String title;
  //final String imageUrl;

  /*ProductItem({
    @required this.id,
    @required this.title,
    @required this.imageUrl,
  });*/

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    final scaffold = ScaffoldMessenger.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          //Consumer is working as Provider.of<Product>(context) but it better to use when u want to run a subpart
          //in a tree like at this part where the favorite button is the only thing changes over time.
          leading: Consumer<Product>(
            builder: (ctx, value, child) => IconButton(
              icon: Icon(
                  product.isFavorte ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                try {
                  await product.toggleFavoriteStatus(
                    auth.token,
                    auth.userId,
                  );
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(
                    SnackBar(
                      content: product.isFavorte
                          ? const Text('Item added to Favorites list.')
                          : const Text('Item Removed from Favorites list.'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () => scaffold.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                } catch (error) {
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('$error try agian later'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () => scaffold.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          title: Text(
            product.title,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart_sharp),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(
                  product.id, product.title, product.price, product.imageUrl);
              //hide a massage bar at the botton with undo button before showing another one
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //show a massage bar at the botton with undo button
              //Scaffold.of(context).showSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => cart.removeSingleItem(product.id),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
