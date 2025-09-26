import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_popup/src/data/model/popup_config.dart';
import 'package:dynamic_popup/src/data/model/popup_models.dart';
import 'package:dynamic_popup/src/data/repository/dynamic_popup_repository.dart';
import 'package:dynamic_popup/src/ui/dynamic_popup_widget.dart';

/// Service for managing dynamic popups
class DynamicPopupService extends GetxService {
  static const String _storageKeyPrefix = 'dynamic_popup_state_';
  
  final RxBool _isCheckingPopup = false.obs;
  final Map<String, PopupState> _popupStates = {};
  final Set<String> _shownInSession = {}; // Only for current session

  bool get isCheckingPopup => _isCheckingPopup.value;

  @override
  void onInit() {
    super.onInit();
    _loadLocalPopupStates();
    print('DynamicPopupService initialized - session tracking reset');
  }

  /// Load popup states from local storage (only permanent states)
  void _loadLocalPopupStates() {
    try {
      // NOT loading _shownInSession from storage - resets on every app start
      print('Popup states loaded - session tracking starts fresh');
    } catch (e) {
      print('Error loading popup states: $e');
    }
  }

  /// Reset all popup states (for testing)
  void resetAllPopupStates() {
    try {
      // Note: _storage.getKeys() might not be available in SharedPreferences
      // Reset only what we have in memory and clear session
      _popupStates.clear();
      _shownInSession.clear(); // Reset session too

      print('All popup states reset');
    } catch (e) {
      print('Error resetting all popup states: $e');
    }
  }

  /// Check and show popup for a screen
  Future<bool> checkAndShowPopup({
    required String screenName,
    String? userId,
    bool force = false,
  }) async {
    if (_isCheckingPopup.value && !force) {
      print('Popup check already in progress, skipping');
      return false;
    }

    _isCheckingPopup.value = true;

    try {
      print('Checking for popup on screen: $screenName');
      
      final apiResponse = await DynamicPopupRepository.checkForPopup(
        screenName: screenName,
        userId: userId,
      );

      if (apiResponse?.hasPopup == true && apiResponse?.popup != null) {
        final popup = apiResponse!.popup!;
        
        // Check if popup should be shown
        if (_shouldShowPopup(popup)) {
          return await _showPopup(popup, userId: userId);
        } else {
          print('Popup ${popup.id} already shown or expired, skipping');
        }
      } else {
        print('No popup to show for screen: $screenName');
      }

      return false;
    } catch (e) {
      print('Error in checkAndShowPopup: $e');
      return false;
    } finally {
      _isCheckingPopup.value = false;
    }
  }

  /// Check if a popup should be shown
  bool _shouldShowPopup(PopupConfig popup) {
    // Check expiration
    if (popup.isExpired) {
      print('Popup ${popup.id} is expired');
      return false;
    }

    // Check if already shown in session
    if (_shownInSession.contains(popup.id)) {
      print('Popup ${popup.id} already shown in session');
      return false;
    }

    // Check showOnce
    if (popup.showOnce) {
      final state = _getPopupState(popup.id);
      if (state?.isCompleted == true || state?.wasDismissed == true) {
        print('Popup ${popup.id} already completed or dismissed');
        return false;
      }
    }

    return true;
  }

  /// Get popup state by ID
  PopupState? _getPopupState(String popupId) {
    return _popupStates[popupId];
  }

  /// Save popup state to local storage
  Future<void> _savePopupState(PopupState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storageKeyPrefix${state.popupId}';
      final json = jsonEncode(state.toJson());
      await prefs.setString(key, json);
    } catch (e) {
      print('Error saving popup state: $e');
    }
  }

  /// Show a popup
  Future<bool> _showPopup(PopupConfig popup, {String? userId}) async {
    try {
      print('Showing popup: ${popup.id}');
      
      // Mark as shown in session (only in memory)
      _shownInSession.add(popup.id);
      
      // Track the view
      await _trackPopupShown(popup.id, userId: userId);

      var wasCompleted = false;

      await Get.dialog(
        DynamicPopupWidget(
          config: popup,
          onCompleted: (response) {
            wasCompleted = true;
            _handlePopupCompleted(response, userId: userId);
          },
          onDismissed: () {
            _handlePopupDismissed(popup.id, userId: userId);
          },
        ),
        barrierDismissible: !popup.isBlocking,
      );

      return wasCompleted;
    } catch (e) {
      print('Error showing popup: $e');
      return false;
    }
  }

  /// Handle popup completion
  void _handlePopupCompleted(PopupResponse response, {String? userId}) {
    print('Popup completed: ${response.popupId}');
    
    // Update local state
    final state = PopupState(
      popupId: response.popupId,
      firstShown: DateTime.now(),
      completed: DateTime.now(),
    );
    _popupStates[response.popupId] = state;
    _savePopupState(state);

    // Submit response to backend
    _submitPopupResponse(response);
  }

  /// Handle popup dismissal
  void _handlePopupDismissed(String popupId, {String? userId}) {
    print('Popup dismissed: $popupId');
    
    // Update local state
    final state = PopupState(
      popupId: popupId,
      firstShown: DateTime.now(),
      wasDismissed: true,
    );
    _popupStates[popupId] = state;
    _savePopupState(state);

    // Track dismissal
    _trackPopupDismissed(popupId, userId: userId);
  }

  /// Submit popup response to backend
  Future<void> _submitPopupResponse(PopupResponse response) async {
    try {
      final success = await DynamicPopupRepository.submitPopupResponse(
        popupResponse: response,
      );
      
      if (success) {
        print('Popup response submitted successfully');
      } else {
        print('Error submitting popup response');
      }
    } catch (e) {
      print('Exception in submitPopupResponse: $e');
      // TODO: Implement retry logic or queue for offline support
    }
  }

  /// Track popup shown
  Future<void> _trackPopupShown(String popupId, {String? userId}) async {
    try {
      await DynamicPopupRepository.markPopupAsShown(
        popupId: popupId,
        userId: userId,
      );
    } catch (e) {
      print('Error tracking popup shown: $e');
    }
  }

  /// Track popup dismissed
  Future<void> _trackPopupDismissed(String popupId, {String? userId}) async {
    try {
      await DynamicPopupRepository.markPopupAsDismissed(
        popupId: popupId,
        userId: userId,
      );
    } catch (e) {
      print('Error tracking popup dismissed: $e');
    }
  }

  /// Show popup by ID
  Future<bool> showPopupById(String popupId, {String? userId}) async {
    try {
      final popup = await DynamicPopupRepository.getPopupById(popupId);
      if (popup != null) {
        return await _showPopup(popup, userId: userId);
      }
      return false;
    } catch (e) {
      print('Error showing popup by ID: $e');
      return false;
    }
  }

  /// Reset popup state for a specific ID (for testing)
  Future<void> resetPopupState(String popupId) async {
    try {
      await DynamicPopupRepository.resetPopupState(popupId: popupId);
      _popupStates.remove(popupId);
      _shownInSession.remove(popupId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_storageKeyPrefix$popupId');
      print('Popup state reset for: $popupId');
    } catch (e) {
      print('Error resetting popup state: $e');
    }
  }
}
