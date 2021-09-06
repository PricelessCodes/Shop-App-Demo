import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

import '../providers/auth.dart';

import '../helper/custom_route.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: <Widget>[
              AppBar(
                title: const Text('Shop Drawer'),
                //automaticallyImplyLeading: false, means it will never add a back button here
                automaticallyImplyLeading: false,
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: const Text('Shop'),
                onTap: () => Navigator.of(context).pushReplacementNamed('/'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.payment),
                title: const Text('My Orders'),
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(OrdersScreen.routeName),
                /*onTap: () => Navigator.of(context).pushReplacement(
                  CustomRoute(
                    builder: (ctx) => OrdersScreen(),
                  ),
                ),*/
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.edit),
                title: const Text('Manage My Products'),
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(UserProductsScreen.routeName),
              ),
            ],
          ),
          Divider(),
          Container(
            color: Colors.red,
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: const Text('Log out'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}
