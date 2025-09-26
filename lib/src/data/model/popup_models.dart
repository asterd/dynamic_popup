import 'package:dynamic_popup/src/data/model/popup_config.dart';

// Model for API response when checking for popups
class PopupApiResponse {
  final bool hasPopup;
  final PopupConfig? popup;
  final String? message;

  PopupApiResponse({
    required this.hasPopup,
    this.popup,
    this.message,
  });

  factory PopupApiResponse.fromJson(Map<String, dynamic> json) {
    return PopupApiResponse(
      hasPopup: json['hasPopup'] as bool? ?? false,
      popup: json['popup'] != null 
          ? PopupConfig.fromJson(json['popup'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPopup': hasPopup,
      'popup': popup?.toJson(),
      'message': message,
    };
  }
}

// Model for popup response data
class PopupResponse {
  final String popupId;
  final Map<String, dynamic> responses;
  final DateTime timestamp;
  final bool wasCompleted;

  PopupResponse({
    required this.popupId,
    required this.responses,
    required this.timestamp,
    this.wasCompleted = true,
  });

  factory PopupResponse.fromJson(Map<String, dynamic> json) {
    return PopupResponse(
      popupId: json['popupId'] as String,
      responses: Map<String, dynamic>.from(json['responses'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      wasCompleted: json['wasCompleted'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'popupId': popupId,
      'responses': responses,
      'timestamp': timestamp.toIso8601String(),
      'wasCompleted': wasCompleted,
    };
  }
}

// Model for tracking popup state
class PopupState {
  final String popupId;
  final DateTime? firstShown;
  final DateTime? completed;
  final bool wasDismissed;

  PopupState({
    required this.popupId,
    this.firstShown,
    this.completed,
    this.wasDismissed = false,
  });

  bool get isCompleted => completed != null;
  bool get wasEverShown => firstShown != null;

  factory PopupState.fromJson(Map<String, dynamic> json) {
    return PopupState(
      popupId: json['popupId'] as String,
      firstShown: json['firstShown'] != null
          ? DateTime.parse(json['firstShown'] as String)
          : null,
      completed: json['completed'] != null
          ? DateTime.parse(json['completed'] as String)
          : null,
      wasDismissed: json['wasDismissed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'popupId': popupId,
      'firstShown': firstShown?.toIso8601String(),
      'completed': completed?.toIso8601String(),
      'wasDismissed': wasDismissed,
    };
  }
}
