import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';

class OrdersService {
  final Crud _crud = Crud();

  // Get authentication headers
  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found. Please login again.");
    }
    return {"Authorization": "Bearer $token"};
  }

  // Create order
  Future<Map<String, dynamic>> createOrder({
    required String deliveryMethod,
    required String paymentType,
    String? addressId,
    String? storeId,
    String? paymentMethodId,
    String? notes,
  }) async {
    try {
      final headers = _getAuthHeaders();

      Map<String, dynamic> data = {
        "delivery_method": deliveryMethod,
        "payment_type": paymentType,
      };

      if (deliveryMethod == 'delivery' && addressId != null) {
        data["address_id"] = addressId;
      }
      if (deliveryMethod == 'pickup' && storeId != null) {
        data["store_id"] = storeId;
      }
      if (paymentType == 'online' && paymentMethodId != null) {
        data["payment_method_id"] = paymentMethodId;
      }
      if (notes != null && notes.isNotEmpty) {
        data["notes"] = notes;
      }

      var response = await _crud.postRequest(
        AppLink.createOrder,
        data,
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'data': response["data"],
          'message': response["message"] ?? 'Order placed successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to place order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating order: ${e.toString()}',
      };
    }
  }

  // Get user orders
  Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = _getAuthHeaders();

      Map<String, dynamic> data = {
        "page": page.toString(),
        "limit": limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        data["status"] = status;
      }

      var response = await _crud.postRequest(
        AppLink.getOrders,
        data,
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
          'message': response['message'] ?? 'Failed to load orders',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading orders: ${e.toString()}',
      };
    }
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.getOrderDetails,
        {
          "order_id": orderId,
        },
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
          'message': response['message'] ?? 'Failed to load order details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading order details: ${e.toString()}',
      };
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      final headers = _getAuthHeaders();

      Map<String, dynamic> data = {
        "order_id": orderId,
      };

      if (reason != null && reason.isNotEmpty) {
        data["reason"] = reason;
      }

      var response = await _crud.postRequest(
        AppLink.cancelOrder,
        data,
        headers: headers,
      );

      if (response["status"] == "success") {
        return {
          'success': true,
          'data': response["data"],
          'message': response["message"] ?? 'Order cancelled successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error cancelling order: ${e.toString()}',
      };
    }
  }

  // Track order
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.trackOrder,
        {
          "order_id": orderId,
        },
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
          'message': response['message'] ?? 'Failed to track order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tracking order: ${e.toString()}',
      };
    }
  }
}