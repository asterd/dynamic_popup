import 'package:dynamic_popup/dynamic_popup.dart';

/// Base implementation of DynamicPopupRepository
/// Users can extend this class and override only the methods they need
/// Only checkForPopup and submitPopupResponse are required to be implemented
abstract class BaseDynamicPopupRepository extends DynamicPopupRepository {
  // Users must implement these two methods
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  });

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  });

  // Optional methods can be overridden
  @override
  Future<void> popupShown({
    required String popupId,
    String? userId,
  }) async {
    // Default implementation does nothing
    super.popupShown(popupId: popupId, userId: userId);
  }

  @override
  Future<void> popupDismissed({
    required String popupId,
    String? userId,
  }) async {
    // Default implementation does nothing
    super.popupDismissed(popupId: popupId, userId: userId);
  }
}