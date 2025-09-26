// Model for dynamic popup configuration
class PopupConfig {
  final String id;
  final String title;
  final String markdownContent;
  final bool isBlocking;
  final bool showOnce;
  final int? priority;
  final DateTime? expiryDate;
  final List<String> targetScreens;
  final Map<String, dynamic>? metadata;

  PopupConfig({
    required this.id,
    required this.title,
    required this.markdownContent,
    this.isBlocking = false,
    this.showOnce = true,
    this.priority,
    this.expiryDate,
    this.targetScreens = const [],
    this.metadata,
  });

  factory PopupConfig.fromJson(Map<String, dynamic> json) {
    return PopupConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      markdownContent: json['markdownContent'] as String,
      isBlocking: json['isBlocking'] as bool? ?? false,
      showOnce: json['showOnce'] as bool? ?? true,
      priority: json['priority'] as int?,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      targetScreens: List<String>.from(json['targetScreens'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'markdownContent': markdownContent,
      'isBlocking': isBlocking,
      'showOnce': showOnce,
      'priority': priority,
      'expiryDate': expiryDate?.toIso8601String(),
      'targetScreens': targetScreens,
      'metadata': metadata,
    };
  }

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  
  bool shouldShowOnScreen(String screenName) {
    return targetScreens.isEmpty || targetScreens.contains(screenName);
  }
}
