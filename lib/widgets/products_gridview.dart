import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import './product_item.dart';

class ProductsGridView extends StatelessWidget {
  final bool showOnlyFavorites;

  ProductsGridView({@required this.showOnlyFavorites});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showOnlyFavorites ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //2 childs per row
        childAspectRatio: 3 / 2, //ration between height to width (H:W)
        crossAxisSpacing: 10, //length between coloums
        mainAxisSpacing: 10, //length between rows
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        //because of the way the listed widgets are recycled and the data changes and the provider wouldn't keep up with that
        //at create or builder with ctx as each provider was attached to a recycled widget
        //but the .value constructor will keep up with that and will not be any bugs exist.
        //create: create: (ctx) => products[index],
        value: products[index],
        child: ProductItem(
            //id: products[index].id,
            //title: products[index].title,
            //imageUrl: products[index].imageUrl,
            ),
      ),
    );
  }
}
