import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart';

class OrderItem extends StatefulWidget {
  final int orderNumber;
  final Order order;

  OrderItem({@required this.orderNumber, @required this.order});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              child: FittedBox(child: Text('#${widget.orderNumber}')),
            ),
            title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
            subtitle: Text(
                DateFormat('dd/mm/yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(
                  () => _expanded = !_expanded,
                );
              },
            ),
          ),
          AnimatedContainer(
            height: _expanded
                ? min(widget.order.cartProducts.length * 20.0, 80)
                : 0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListView(
              children: widget.order.cartProducts
                  .map(
                    (product) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${product.quantity}x   \$${product.price}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
