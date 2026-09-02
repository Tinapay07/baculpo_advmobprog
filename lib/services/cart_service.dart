import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cart.dart';

class CartService {
  static const _baseUrl = 'https://dummyjson.com/carts';

  // ENHANCEMENT 3: fetch carts for one user and return the user's first cart.
  Future<Cart> getCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/user/$userId'));
    _ensureSuccess(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final carts = (json['carts'] as List? ?? [])
        .map((cart) => Cart.fromJson(cart as Map<String, dynamic>))
        .toList();

    if (carts.isEmpty) {
      throw StateError('No cart was found for user $userId.');
    }
    return carts.first;
  }

  // ENHANCEMENT 3: getById support for the /carts/{id} endpoint.
  Future<Cart> getCartById(int cartId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$cartId'));
    _ensureSuccess(response);
    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ENHANCEMENT 3: POST a product id and quantity to DummyJSON's add-cart API.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );
    _ensureSuccess(response);
    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cart request failed (${response.statusCode}).');
    }
  }
}
