import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dynamic_popup/dynamic_popup.dart';

/// Custom implementation of the DynamicPopupRepository
/// This example shows how to connect to a real backend API
class CustomDynamicPopupRepository extends BaseDynamicPopupRepository {
  static const String _baseUrl = 'https://your-api-domain.com/api';
  
  /// Check if there are popups to show for a specific screen
  /// This is a required method that must be implemented
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/popup/check')
          .replace(queryParameters: {
            'screen': screenName,
            if (userId != null) 'userId': userId,
          });
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return PopupApiResponse.fromJson(jsonResponse);
      } else {
        print('Error checking for popup: ${response.statusCode}');
        return PopupApiResponse(hasPopup: false);
      }
    } catch (e) {
      print('Exception in checkForPopup: $e');
      return PopupApiResponse(hasPopup: false);
    }
  }

  /// Submit the user's response to the popup
  /// This is a required method that must be implemented
  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    try {
      print('Submitting popup response JSON: ${jsonEncode(popupResponse.toJson())}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/popup/response'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(popupResponse.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Exception in submitPopupResponse: $e');
      return false;
    }
  }

  /// Get a specific popup by ID (for testing)
  /// This is an optional method - override only if you need this functionality
  @override
  Future<PopupConfig?> getPopupById(String popupId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/popup/$popupId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return PopupConfig.fromJson(jsonResponse);
      } else {
        print('Error getting popup by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getPopupById: $e');
      return null;
    }
  }
}