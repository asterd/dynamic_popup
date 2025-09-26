import 'package:dynamic_popup/dynamic_popup.dart';
import 'package:dynamic_popup/src/data/repository/dynamic_popup_repository.dart';

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
}