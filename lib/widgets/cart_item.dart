import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String productId;
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    @required this.productId,
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).errorColor,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_forever_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content:
                const Text('Do you want to remove the item from the cart?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) =>
          Provider.of<Cart>(context, listen: false).removeItem(productId),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            leading: Container(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: GridTile(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  footer: Container(
                    height: 20,
                    child: GridTileBar(
                      backgroundColor: Colors.black87,
                      title: Text(
                        '\$$price',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            /*CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),*/
            title: Text(title),
            subtitle: Text('\$${price * quantity}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
