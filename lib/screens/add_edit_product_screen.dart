import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/add-edit-product';

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  String _appBarTitle = '';
  //no need for focus nodes now because it is automatic
  //when we click next on the keyboard it make the focus go from the title field
  //to the price field but it was not need it becayse it was already working without it
  //but at max course, he needed to add it (maybe they make it automatic in a flutter update)
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  var _isImageValid = false;
  final _form = GlobalKey<FormState>();
  var _addEditProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _isInit = true;
  var _isloading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    // we need to dispose any focus nodes because after state is cleared and disposed
    // the focus nodes still stay in memory so we have to clear them at dispose method.
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final _appBarTitleAndIdIfExist =
          ModalRoute.of(context).settings.arguments as List<String>;
      _appBarTitle = _appBarTitleAndIdIfExist[0];
      if (_appBarTitleAndIdIfExist.length > 1) {
        final String productId = _appBarTitleAndIdIfExist[1];
        _addEditProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _imageUrlController.text = _addEditProduct.imageUrl;
        _isImageValid = true;
      }

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {
        _isImageValid = false;
        if ((!_imageUrlController.text.startsWith('https') &&
                !_imageUrlController.text.startsWith('http')) ||
            (!_imageUrlController.text.endsWith('.png') &&
                !_imageUrlController.text.endsWith('.jpg') &&
                !_imageUrlController.text.endsWith('.jpeg'))) return;
        _isImageValid = true;
      });
    }
  }

  Future<void> _saveForm(BuildContext context) async {
    final bool isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isloading = true;
    });
    if (_addEditProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_addEditProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occured!'),
            content: const Text('Something went wrong. Try again later.'),
            actions: [
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
      /*finally {
        setState(() {
          _isloading = false;
        });
        Navigator.of(context).pop();
      }*/
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_addEditProduct.id, _addEditProduct);
      } catch (error) {
        //we can do something like we did at adding a producted
        throw error;
      }
    }
    setState(() {
      _isloading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save), onPressed: () => _saveForm(context))
        ],
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                onWillPop: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you want to dismiss your editing?'),
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
                ),
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      initialValue: _addEditProduct.id != null
                          ? _addEditProduct.title
                          : '',
                      maxLength: 40,
                      //textInputAction: TextInputAction.next,
                      // no need for it it is working automatic on flutter now
                      onFieldSubmitted: (textInField) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please Enter a title. (Example: Watch, Red Shirt)';
                        return null;
                      },
                      onSaved: (value) => _addEditProduct = Product(
                        id: _addEditProduct.id,
                        title: value,
                        price: _addEditProduct.price,
                        description: _addEditProduct.description,
                        imageUrl: _addEditProduct.imageUrl,
                        isFavorte: _addEditProduct.isFavorte,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Price'),
                      initialValue: _addEditProduct.id != null
                          ? _addEditProduct.price.toString()
                          : '',
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      // no need for it it is working automatic on flutter now
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (textInField) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please Enter a price. (Example: 120, 120.99)';
                        if (double.tryParse(value) == null)
                          return 'Please provide a valid price. (Example: 120, 120.99)';
                        if (double.parse(value) < 0)
                          return 'Please enter a positve price. (Example: 120, 120.99)';
                        return null;
                      },
                      onSaved: (value) => _addEditProduct = Product(
                        id: _addEditProduct.id,
                        title: _addEditProduct.title,
                        price: double.parse(value),
                        description: _addEditProduct.description,
                        imageUrl: _addEditProduct.imageUrl,
                        isFavorte: _addEditProduct.isFavorte,
                      ),
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      initialValue: _addEditProduct.id != null
                          ? _addEditProduct.description
                          : '',
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      // no need for it it is working automatic on flutter now
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please Enter a description. (Example: this watch is made by...etc.)';
                        return null;
                      },
                      onSaved: (value) => _addEditProduct = Product(
                        id: _addEditProduct.id,
                        title: _addEditProduct.title,
                        price: _addEditProduct.price,
                        description: value,
                        imageUrl: _addEditProduct.imageUrl,
                        isFavorte: _addEditProduct.isFavorte,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty ||
                                  !_isImageValid
                              ? const Center(child: Text('Enter a URL'))
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  //fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () => setState(() {}),
                            onFieldSubmitted: (_) => _saveForm(context),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter an image URL.';
                              }
                              if (!value.startsWith('https') &&
                                  !value.startsWith('http')) {
                                return 'Please Enter a valid URL.';
                              }
                              if (!value.endsWith('png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('jpeg')) {
                                return 'Please Enter a valid image URL.';
                              }
                              return null;
                            },
                            onSaved: (value) => _addEditProduct = Product(
                              id: _addEditProduct.id,
                              title: _addEditProduct.title,
                              price: _addEditProduct.price,
                              description: _addEditProduct.description,
                              imageUrl: value,
                              isFavorte: _addEditProduct.isFavorte,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
