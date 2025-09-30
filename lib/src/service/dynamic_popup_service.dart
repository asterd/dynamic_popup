import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_popup/src/data/model/popup_config.dart';
import 'package:dynamic_popup/src/data/model/popup_models.dart';
import 'package:dynamic_popup/src/data/repository/dynamic_popup_repository.dart';
import 'package:dynamic_popup/src/ui/dynamic_popup_widget.dart';
import 'package:flutter/material.dart';

/// Service for managing dynamic popups
/// Note: This service needs to be initialized by your app and provided to widgets
class DynamicPopupService {
  static const String _storageKeyPrefix = 'dynamic_popup_state_';
  
  final DynamicPopupRepository repository;
  final Map<String, PopupState> _popupStates = {};
  final Set<String> _shownInSession = {}; // Only for current session
  bool _isCheckingPopup = false;

  bool get isCheckingPopup => _isCheckingPopup;

  /// Create a new DynamicPopupService with a repository
  DynamicPopupService({required this.repository});

  /// Initialize the service
  /// Call this when your app starts
  void init() {
    _loadLocalPopupStates();
    print('DynamicPopupService initialized - session tracking reset');
  }

  /// Load popup states from local storage (only permanent states)
  void _loadLocalPopupStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (var key in keys) {
        if (key.startsWith(_storageKeyPrefix)) {
          final json = prefs.getString(key);
          if (json != null) {
            try {
              final state = PopupState.fromJson(jsonDecode(json));
              _popupStates[state.popupId] = state;
            } catch (e) {
              print('Error parsing popup state for key $key: $e');
            }
          }
        }
      }
      
      print('Loaded ${_popupStates.length} popup states from local storage');
      // NOT loading _shownInSession from storage - resets on every app start
      print('Popup states loaded - session tracking starts fresh');
    } catch (e) {
      print('Error loading popup states: $e');
    }
  }

  /// Reset all popup states (for testing)
  void resetAllPopupStates() {
    try {
      // Clear all popup states from memory
      _popupStates.clear();
      _shownInSession.clear(); // Reset session too
      
      // Clear all popup states from storage
      _clearAllStoredPopupStates();
      
      print('All popup states reset');
    } catch (e) {
      print('Error resetting all popup states: $e');
    }
  }

  /// Clear all stored popup states from local storage
  Future<void> _clearAllStoredPopupStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (var key in keys) {
        if (key.startsWith(_storageKeyPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing stored popup states: $e');
    }
  }

  /// Check and show popup for a screen
  Future<bool> checkAndShowPopup({
    required String screenName,
    String? userId,
    bool force = false,
    required BuildContext context, // Added context parameter
  }) async {
    if (_isCheckingPopup && !force) {
      print('Popup check already in progress, skipping');
      return false;
    }

    _isCheckingPopup = true;

    try {
      print('Checking for popup on screen: $screenName');
      
      final apiResponse = await repository.checkForPopup(
        screenName: screenName,
        userId: userId,
      );

      if (apiResponse?.hasPopup == true && apiResponse?.popup != null) {
        final popup = apiResponse!.popup!;
        
        // Check if popup should be shown
        if (_shouldShowPopup(popup)) {
          // Check if the context is still mounted before showing the dialog
          if (!context.mounted) return false;
          
          return await _showPopup(popup, context: context, userId: userId);
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
      _isCheckingPopup = false;
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
  Future<bool> _showPopup(PopupConfig popup, {
    required BuildContext context, // Added context parameter
    String? userId
  }) async {
    try {
      print('Showing popup: ${popup.id}');
      
      // Mark as shown in session (only in memory)
      _shownInSession.add(popup.id);
      
      // Call popupShown event
      await repository.popupShown(popupId: popup.id, userId: userId);
      
      var wasCompleted = false;
      bool dialogClosed = false;

      // Using Flutter's showDialog instead of Get.dialog
      await showDialog(
        context: context,
        barrierDismissible: !popup.isBlocking,
        builder: (BuildContext context) {
          return DynamicPopupWidget(
            config: popup,
            onCompleted: (response) {
              if (!dialogClosed) {
                wasCompleted = true;
                _handlePopupCompleted(response, userId: userId);
                dialogClosed = true;
                Navigator.of(context).pop(); // Close the dialog
              }
            },
            onDismissed: () {
              if (!dialogClosed) {
                _handlePopupDismissed(popup.id, userId: userId);
                dialogClosed = true;
                Navigator.of(context).pop(); // Close the dialog
              }
            },
          );
        },
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
  Future<void> _handlePopupDismissed(String popupId, {String? userId}) async {
    print('Popup dismissed: $popupId');
    
    // Update local state
    final state = PopupState(
      popupId: popupId,
      firstShown: DateTime.now(),
      wasDismissed: true,
    );
    _popupStates[popupId] = state;
    _savePopupState(state);
    
    // Call popupDismissed event
    await repository.popupDismissed(popupId: popupId, userId: userId);
  }

  /// Submit popup response to backend
  Future<void> _submitPopupResponse(PopupResponse response) async {
    try {
      final success = await repository.submitPopupResponse(
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

  /// Show popup by ID
  Future<bool> showPopupById(String popupId, {
    String? userId,
    required BuildContext context, // Added context parameter
  }) async {
    try {
      final popup = await repository.getPopupById(popupId);
      if (popup != null) {
        // Check if the context is still mounted before showing the dialog
        if (!context.mounted) return false;
        
        return await _showPopup(popup, context: context, userId: userId);
      } else {
        // Popup not found - this is not necessarily an error
        print('Popup with ID $popupId not found');
        return false;
      }
    } catch (e) {
      print('Error showing popup by ID: $e');
      return false;
    }
  }

  /// Reset popup state for a specific ID (for testing)
  Future<void> resetPopupState(String popupId) async {
    try {
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