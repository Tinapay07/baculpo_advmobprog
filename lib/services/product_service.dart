import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final jsonString = await rootBundle.loadString('.idea/products.json');
    final List productsJson = jsonDecode(jsonString);
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  // ENHANCEMENT 1: cart items only contain summary data, so load the full
  // product before reusing ProductDetailsScreen.
  Future<Product> getProductById(int productId) async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/$productId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load product $productId.');
    }
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
