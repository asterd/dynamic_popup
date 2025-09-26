import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dynamic_popup/dynamic_popup.dart';

/// Custom implementation of the DynamicPopupRepository
/// This example shows how to connect to a real backend API
class CustomDynamicPopupRepository extends DynamicPopupRepository {
  static const String _baseUrl = 'https://your-api-domain.com/api';
  
  /// Check if there are popups to show for a specific screen
  static Future<PopupApiResponse?> checkForPopup({
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
        // ignore: avoid_print
        print('Error checking for popup: ${response.statusCode}');
        return PopupApiResponse(hasPopup: false);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Exception in checkForPopup: $e');
      return PopupApiResponse(hasPopup: false);
    }
  }

  /// Submit the user's response to the popup
  static Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/popup/response'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(popupResponse.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Exception in submitPopupResponse: $e');
      return false;
    }
  }

  /// Mark a popup as shown (for tracking)
  static Future<bool> markPopupAsShown({
    required String popupId,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/popup/shown'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'popupId': popupId,
          'timestamp': DateTime.now().toIso8601String(),
          if (userId != null) 'userId': userId,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Exception in markPopupAsShown: $e');
      return false;
    }
  }

  /// Mark a popup as dismissed (closed without completion)
  static Future<bool> markPopupAsDismissed({
    required String popupId,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/popup/dismissed'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'popupId': popupId,
          'timestamp': DateTime.now().toIso8601String(),
          if (userId != null) 'userId': userId,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Exception in markPopupAsDismissed: $e');
      return false;
    }
  }
}