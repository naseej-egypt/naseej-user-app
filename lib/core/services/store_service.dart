import 'dart:convert';
import 'package:naseej/core/class/crud.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/models/store_model.dart';
import 'package:naseej/main.dart';

class StoreService {
  final Crud _crud = Crud();

  // Get authentication headers
  Map<String, String> _getAuthHeaders() {
    final token = sharedPref.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found. Please login again.");
    }
    return {"Authorization": "Bearer $token"};
  }

  Future<Map<String, dynamic>> searchStores({
    String query = '',
    String city = 'All',
    String region = 'All',
  }) async {
    try {
      print('=== STORE SERVICE: Building request ===');

      final Map<String, dynamic> params = {};

      if (query.isNotEmpty) params['query'] = query;
      if (city != 'All') params['city'] = city;
      if (region != 'All') params['region'] = region;

      print('=== STORE SERVICE: Request params ===');
      print(params);

      // Use POST request instead of GET with query parameters
      final response = await _crud.postRequest(
        AppLink.searchStores,
        params,
        headers: _getAuthHeaders(),
      );

      print('=== STORE SERVICE: Raw response ===');
      print(response);

      if (response['status'] == 'success') {
        final data = response['data'];

        if (data != null && data['stores'] is List) {
          final storesData = data['stores'] as List;
          print('=== STORE SERVICE: Parsing ${storesData.length} stores ===');

          final stores = <Store>[];
          for (var storeJson in storesData) {
            try {
              final store = Store.fromJson(storeJson);
              stores.add(store);
            } catch (e) {
              print('=== STORE SERVICE: Error parsing store: $e ===');
              print('Store data: $storeJson');
            }
          }

          final filters = data['filters'] ?? {};
          final searchMeta = data['search_meta'] ?? {};

          return {
            'success': true,
            'stores': stores,
            'filters': filters,
            'searchMeta': searchMeta,
          };
        } else {
          return {
            'success': false,
            'error': 'Invalid data format from server',
          };
        }
      } else {
        return {
          'success': false,
          'error': response['message'] ?? 'Failed to search stores',
        };
      }
    } catch (e) {
      print('=== STORE SERVICE: Exception ===');
      print(e.toString());
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Simple method to get all active stores without filters
  Future<Map<String, dynamic>> getStores() async {
    try {
      print('=== STORE SERVICE: Getting all stores ===');

      // Use POST request with empty parameters
      final response = await _crud.postRequest(
        AppLink.getStores,
        {},
        headers: _getAuthHeaders(),
      );

      print('=== STORE SERVICE: Get stores response ===');
      print(response);

      if (response['status'] == 'success') {
        final data = response['data'];

        if (data != null && data['stores'] is List) {
          final storesData = data['stores'] as List;
          print('=== STORE SERVICE: Parsing ${storesData.length} stores ===');

          final stores = <Store>[];
          for (var storeJson in storesData) {
            try {
              final store = Store.fromJson(storeJson);
              stores.add(store);
            } catch (e) {
              print('=== STORE SERVICE: Error parsing store: $e ===');
              print('Store data: $storeJson');
            }
          }

          return {
            'success': true,
            'data': stores, // Return under 'data' key for consistency
          };
        } else {
          return {
            'success': false,
            'error': 'Invalid data format from server',
          };
        }
      } else {
        return {
          'success': false,
          'error': response['message'] ?? 'Failed to load stores',
        };
      }
    } catch (e) {
      print('=== STORE SERVICE: Exception in getStores ===');
      print(e.toString());
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getStoreDetails(String storeId) async {
    try {
      final response = await _crud.postRequest(
        AppLink.getStoreDetails,
        {"store_id": storeId},
        headers: _getAuthHeaders(),
      );

      if (response['status'] == 'success') {
        final storeData = response['data'];
        final store = Store.fromJson(storeData);

        return {
          'success': true,
          'data': store,
        };
      } else {
        return {
          'success': false,
          'error': response['message'] ?? 'Failed to load store details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}