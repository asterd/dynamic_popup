import 'dart:convert';
import 'package:dynamic_popup/src/data/model/popup_config.dart';
import 'package:dynamic_popup/src/data/model/popup_models.dart';

/// Repository for API calls related to dynamic popups
/// This is a base class that should be extended by the user with their own implementation
/// Only checkForPopup and submitPopupResponse are required, other methods are optional
abstract class DynamicPopupRepository {
  
  /// Check if there are popups to show for a specific screen
  /// This method is REQUIRED and must be implemented by the user
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  });

  /// Submit the user's response to the popup
  /// This method is REQUIRED and must be implemented by the user
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  });

  /// Mark a popup as shown (for tracking)
  /// This method is OPTIONAL - override only if you need this functionality
  Future<bool> markPopupAsShown({
    required String popupId,
    String? userId,
  }) async {
    // Default implementation does nothing
    return true;
  }

  /// Mark a popup as dismissed (closed without completion)
  /// This method is OPTIONAL - override only if you need this functionality
  Future<bool> markPopupAsDismissed({
    required String popupId,
    String? userId,
  }) async {
    // Default implementation does nothing
    return true;
  }

  /// Get all available popups (for testing/admin)
  /// This method is OPTIONAL - override only if you need this functionality
  Future<List<PopupConfig>?> getAllPopups() async {
    // Default implementation does nothing
    return null;
  }

  /// Get a specific popup by ID (for testing)
  /// This method is OPTIONAL - override only if you need this functionality
  Future<PopupConfig?> getPopupById(String popupId) async {
    // Default implementation does nothing
    return null;
  }

  /// Get the state of all popups for a user
  /// This method is OPTIONAL - override only if you need this functionality
  Future<List<PopupState>?> getUserPopupStates({
    String? userId,
  }) async {
    // Default implementation does nothing
    return null;
  }

  /// Reset the state of a popup (for testing)
  /// This method is OPTIONAL - override only if you need this functionality
  Future<bool> resetPopupState({
    required String popupId,
    String? userId,
  }) async {
    // Default implementation does nothing
    return true;
  }
}