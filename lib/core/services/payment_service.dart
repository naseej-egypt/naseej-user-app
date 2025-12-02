import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/models/payment_method_model.dart';
import 'package:naseej/main.dart';

class PaymentService {
  final Crud _crud = Crud();

  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found. Please login again.");
    }
    return {"Authorization": "Bearer $token"};
  }

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.getPaymentMethods,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        List<dynamic> paymentMethodsData = response["data"]["payment_methods"] ?? [];
        List<PaymentMethodModel> paymentMethods = paymentMethodsData.map((methodJson) => PaymentMethodModel.fromJson(methodJson)).toList();

        return {
          'success': true,
          'data': paymentMethods,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to load payment methods',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading payment methods: ${e.toString()}',
      };
    }
  }
}