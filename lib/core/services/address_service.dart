import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/models/address_model.dart';
import 'package:naseej/main.dart';

class AddressService {
  final Crud _crud = Crud();

  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found. Please login again.");
    }
    return {"Authorization": "Bearer $token"};
  }

  Future<Map<String, dynamic>> getAddresses() async {
    try {
      final headers = _getAuthHeaders();

      var response = await _crud.postRequest(
        AppLink.getAddresses,
        {},
        headers: headers,
      );

      if (response["status"] == "success") {
        List<dynamic> addressesData = response["data"]["addresses"] ?? [];
        List<AddressModel> addresses = addressesData.map((addressJson) => AddressModel.fromJson(addressJson)).toList();

        return {
          'success': true,
          'data': addresses,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to load addresses',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading addresses: ${e.toString()}',
      };
    }
  }
}