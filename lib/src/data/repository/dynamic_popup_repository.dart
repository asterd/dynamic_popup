import 'package:dynamic_popup/src/data/model/popup_config.dart';
import 'package:dynamic_popup/src/data/model/popup_models.dart';

/// Repository for API calls related to dynamic popups
/// This is a base class that should be extended by the user with their own implementation
/// Only checkForPopup and submitPopupResponse are required, other methods have default implementations
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

  /// Get a specific popup by ID (for testing)
  /// This method is OPTIONAL - override only if you need this functionality
  Future<PopupConfig?> getPopupById(String popupId) async {
    // Default implementation does nothing
    return null;
  }
}