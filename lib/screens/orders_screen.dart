import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetProducts(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.hasError) {
                return Text('Error at Orders Screen');
              } else {
                return Consumer<Orders>(builder: (ctx, ordersData, child) {
                  if (ordersData.orders.length <= 0) {
                    return Center(child: Text('No orders placed yet!'));
                  } else {
                    return ListView.builder(
                      itemCount: ordersData.orders.length,
                      itemBuilder: (_, i) => OrderItem(
                        orderNumber: (ordersData.orders.length - i),
                        order: ordersData.orders[i],
                      ),
                    );
                  }
                });
              }
            }
          }),
    );
  }
}
