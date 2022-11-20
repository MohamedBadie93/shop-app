import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/product.dart';
import 'package:shop_app_3/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product-screen';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _priceFocusNode = FocusNode();
  final _descretionNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _formGolbalKey = GlobalKey<FormState>();

  var _editingProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0.0,
    imageUrl: '',
  );

  var loadedProdut = false;
  var _isLoading = false;

  void _imageFocusNodeListner() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _submitForm() async {
    final isValid = _formGolbalKey.currentState!.validate();
    if (isValid) {
      _formGolbalKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final bool isNewProduct = _editingProduct.id.isEmpty;
      if (isNewProduct) {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_editingProduct);
        } catch (error) {
          await showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text("Error happends"),
                  content: Text(error.toString()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("Okay"),
                    )
                  ],
                );
              });
        } finally {
          // setState(() {
          //   _isLoading = false;
          // });
          // Navigator.of(context).pop();
        }
      } else {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editingProduct.id, _editingProduct);
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_imageFocusNodeListner);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!loadedProdut) {
      String? productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        final desiredProduct =
            Provider.of<Products>(context, listen: false).findByID(productId);
        _editingProduct = desiredProduct;
        _imageUrlController.text = desiredProduct.imageUrl;
      }
    }

    loadedProdut = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_imageFocusNodeListner);
    _priceFocusNode.dispose();
    _descretionNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: () {
              _submitForm();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formGolbalKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "title",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        initialValue: _editingProduct.title,
                        validator: (value) {
                          if (value!.isEmpty) return "Please Enter Title";
                          return null;
                        },
                        onSaved: (newValue) {
                          _editingProduct = Product(
                            id: _editingProduct.id,
                            title: newValue!,
                            description: _editingProduct.description,
                            price: _editingProduct.price,
                            imageUrl: _editingProduct.imageUrl,
                            isFavorite: _editingProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Price"),
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descretionNode);
                        },
                        initialValue: _editingProduct.price == 0.0
                            ? ''
                            : _editingProduct.price.toString(),
                        validator: (value) {
                          if (value!.isEmpty) return "Please Enter Price";
                          if (double.tryParse(value) == null)
                            return "Please Enter a valid number";
                          if (double.parse(value) <= 0)
                            return "Please Enter a number that's more than 0";
                          return null;
                        },
                        onSaved: (newValue) {
                          _editingProduct = Product(
                            id: _editingProduct.id,
                            title: _editingProduct.title,
                            description: _editingProduct.description,
                            price: double.parse(newValue!),
                            imageUrl: _editingProduct.imageUrl,
                            isFavorite: _editingProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Description",
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descretionNode,
                        textInputAction: TextInputAction.next,
                        initialValue: _editingProduct.description,
                        validator: (value) {
                          if (value!.isEmpty) return "Please Enter Description";
                          if (value.length < 10)
                            return "Please enter 10 letters or more";
                          return null;
                        },
                        onSaved: (newValue) {
                          _editingProduct = Product(
                            id: _editingProduct.id,
                            title: _editingProduct.title,
                            description: newValue!,
                            price: _editingProduct.price,
                            imageUrl: _editingProduct.imageUrl,
                            isFavorite: _editingProduct.isFavorite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text("Enter url")
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Enter an image url"),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onEditingComplete: () {
                                setState(() {});
                                _submitForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty)
                                  return "Please Enter image url";
                                if (!value.startsWith('http://') &&
                                    !value.startsWith('https://'))
                                  return "Please Enter a valid url";
                                if (!value.endsWith('jpg') &&
                                    !value.endsWith('jpeg') &&
                                    !value.endsWith('png'))
                                  return "Please Enter an  image url";
                                return null;
                              },
                              onSaved: (newValue) {
                                _editingProduct = Product(
                                  id: _editingProduct.id,
                                  title: _editingProduct.title,
                                  description: _editingProduct.description,
                                  price: _editingProduct.price,
                                  imageUrl: newValue!,
                                  isFavorite: _editingProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
