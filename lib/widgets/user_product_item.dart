import 'package:flutter/material.dart';

import '../screens/add_edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final Function deleteProductHandler;

  UserProductItem(
      {@required this.id,
      @required this.title,
      @required this.imageUrl,
      @required this.deleteProductHandler});

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => Navigator.of(context).pushNamed(
                  AddEditProductScreen.routeName,
                  arguments: ['Edit Product', id]),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  await deleteProductHandler(id);

                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('Product is deleted successfully.'),
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
          ],
        ),
      ),
    );
  }
}
