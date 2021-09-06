import 'dart:convert';

import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import './cart.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> cartProducts;
  final DateTime dateTime;

  Order({
    @required this.id,
    @required this.amount,
    @required this.cartProducts,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Order> _orders = [];

  Orders(this.authToken, this.userId, this._orders);

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetProducts() async {
    final url =
        'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/Orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(authToken);
      if (extractedData == null) {
        //print('No Orders at server');
        return;
      }
      final List<Order> emptyList = [];
      extractedData.forEach((orderId, orderData) {
        emptyList.add(
          Order(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            cartProducts: (orderData['products'] as List<dynamic>)
                .map(
                  (prod) => CartItem(
                    id: prod['id'],
                    title: prod['title'],
                    quantity: prod['quantity'],
                    price: prod['price'],
                    imageUrl: prod['imageUrl'],
                  ),
                )
                .toList(),
          ),
        );
      });
      _orders = emptyList.reversed.toList();
      notifyListeners();
    } catch (error) {
      print('error at fetching orders $error');
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final url =
        'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/Orders/$userId.json?auth=$authToken';
    final dateStamp = DateTime.now();
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'products': cartProducts
                .map((item) => {
                      'id': item.id,
                      'title': item.title,
                      'price': item.price,
                      'quantity': item.quantity,
                      'imageUrl': item.imageUrl,
                    })
                .toList(),
            'amount': amount,
            'dateTime': dateStamp.toIso8601String(),
          }));
      if (response.statusCode >= 400) {
        throw HttpException('Faild to order your cart.');
      }

      _orders.insert(
        0,
        Order(
          id: json.decode(response.body)['name'],
          amount: amount,
          cartProducts: cartProducts,
          dateTime: dateStamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      print('error at adding order $error');
    }
  }
}
