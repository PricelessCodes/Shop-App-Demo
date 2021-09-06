import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorte;

  Product({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.description,
    @required this.imageUrl,
    this.isFavorte = false,
  });

  void _setFavoriteValue(bool newValue) {
    isFavorte = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldStatues = isFavorte;

    _setFavoriteValue(!oldStatues);

    var url =
        'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken';
    if (isFavorte == true) {
      final response = await http.put(Uri.parse(url),
          body: json.encode(
            isFavorte,
          ));
      if (response.statusCode >= 400) {
        _setFavoriteValue(oldStatues);
        throw HttpException('Failed to change Item Statues.');
      }
    } else {
      url =
          'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode >= 400) {
        _setFavoriteValue(oldStatues);
        throw HttpException('Failed to change Item Statues.');
      }
    }
  }
}
