import 'dart:convert';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/models/cart_item.dart';
import 'package:naseej/main.dart';

class CartService {
  final Crud _crud = Crud();

  // Get authentication headers
  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found. Please login again.");
    }
    return {"Authorization": "Bearer $token"};
  }

  // Get cart items
  Future<Map<String, dynamic>> getCart() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.getCart,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'data': response["data"],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to load cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading cart: ${e.toString()}',
      };
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) async {
    try {
      final headers = _getAuthHeaders();

      Map<String, dynamic> data = {
        "product_id": productId,
        "quantity": quantity.toString(),
      };

      if (color != null && color.isNotEmpty) {
        data["color"] = color;
      }
      if (size != null && size.isNotEmpty) {
        data["size"] = size;
      }

      var response = await _crud.postRequest(
        AppLink.addToCart,
        data,
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'data': response["data"],
          'message': response["message"] ?? 'Item added to cart',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to add item to cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding to cart: ${e.toString()}',
      };
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCartItem({
    required String cartId,
    required int quantity,
  }) async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.updateCartItem,
        {
          "cart_id": cartId,
          "quantity": quantity.toString(),
        },
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'data': response["data"],
          'message': response["message"] ?? 'Cart updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating cart: ${e.toString()}',
      };
    }
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeFromCart(String cartId) async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.removeFromCart,
        {
          "cart_id": cartId,
        },
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'message': response["message"] ?? 'Item removed from cart',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to remove item',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error removing item: ${e.toString()}',
      };
    }
  }

  // Clear entire cart
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.clearCart,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'message': response["message"] ?? 'Cart cleared successfully',
          'data': response["data"],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to clear cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error clearing cart: ${e.toString()}',
      };
    }
  }
}