import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /*
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  //bool _showFavoritesOnly = false;

  List<Product> get items {
    /*if (_showFavoritesOnly)
      return _items.where((item) => item.isFavorte).toList();
    */
    return [..._items];
  }

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorte).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((proudct) => proudct.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final String ownerProductsOnly =
        filterByUser ? 'orderBy="ownerId"&equalTo="$userId"' : '';
    var url =
        'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$ownerProductsOnly';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        print('No Items at server');
        return;
      }
      url =
          'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> emptyList = [];
      extractedData.forEach((prodId, prodData) {
        emptyList.add(
          Product(
            id: prodId,
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            isFavorte:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = emptyList;
      notifyListeners();
    } catch (error) {
      print('at fetching products $error');
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'ownerId': userId,
          }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print('at adding a product $error');
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Failed to remove product.');
    }
    existingProduct = null;
  }

  Future<void> updateProduct(String id, Product modifiedproduct) async {
    final int prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      try {
        final url =
            'https://my-shop-project-2095d-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
        await http.patch(Uri.parse(url),
            body: json.encode({
              'title': modifiedproduct.title,
              'price': modifiedproduct.price,
              'description': modifiedproduct.description,
              'imageUrl': modifiedproduct.imageUrl,
            }));
        _items[prodIndex] = modifiedproduct;
        notifyListeners();
      } catch (error) {
        print('Something happened while u r updating a product');
      }
    } else {
      print('Product is not exist');
    }
  }

  /*void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }

  void showFavoritesOnly() {
    _showFavoritesOnly = true;
    notifyListeners();
  }*/
}
