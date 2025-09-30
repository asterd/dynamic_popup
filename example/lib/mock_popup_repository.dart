import 'package:dynamic_popup/dynamic_popup.dart';

/// Mock implementation of DynamicPopupRepository for demonstration purposes
/// This simulates API calls with delayed responses and mock data
class MockDynamicPopupRepository extends BaseDynamicPopupRepository {
  // Mock data for popups
  static final Map<String, PopupConfig> _mockPopups = {
    'home_screen': PopupConfig(
      id: 'welcome_popup',
      title: 'Welcome to Our App!',
      markdownContent: '''
## Welcome!

We're excited to have you here. Take a moment to explore our new features.

:::dc<checkbox id="interests" label="What are you interested in?">
  <option id="updates">Product Updates</option>
  <option id="offers">Special Offers</option>
  <option id="features">New Features</option>
</checkbox>dc:::

:::dc<textarea id="feedback" label="Do you have any feedback?" placeholder="We'd love to hear from you..." />dc:::
      ''',
      isBlocking: false,
      showOnce: true,
    ),
    'settings_screen': PopupConfig(
      id: 'settings_update',
      title: 'Settings Updated',
      markdownContent: '''
## New Settings Available

We've added new privacy settings for better control over your data.

:::dc<radiobutton id="privacy_consent" required label="Do you consent to analytics?">
  <option id="yes">Yes</option>
  <option id="no">No</option>
</radiobutton>dc:::

:::dc<dropdown id="notification_pref" label="Notification preferences">
  <option id="all">All</option>
  <option id="important">Important Only</option>
  <option id="none">None</option>
</dropdown>dc:::
      ''',
      isBlocking: true,
      showOnce: true,
    ),
    'product_screen': PopupConfig(
      id: 'product_survey',
      title: 'Product Feedback',
      markdownContent: '''
# Quick Survey

Help us improve our product with this 30-second survey.

:::dc<textfield id="name" required label="Your Name" placeholder="Enter your name" />dc:::

:::dc<radiobutton id="satisfaction" required label="How satisfied are you?">
  <option id="very_satisfied">Very Satisfied</option>
  <option id="satisfied">Satisfied</option>
  <option id="neutral">Neutral</option>
  <option id="dissatisfied">Dissatisfied</option>
  <option id="very_dissatisfied">Very Dissatisfied</option>
</radiobutton>dc:::

:::dc<textarea id="suggestions" label="Suggestions for improvement" placeholder="Any ideas?" />dc:::

:::dc<checkbox id="contact" label="Can we contact you?">
  <option id="email">Email</option>
  <option id="phone">Phone</option>
</checkbox>dc:::
      ''',
      isBlocking: false,
      showOnce: false, // Allow multiple shows for testing
    ),
  };

  // Track shown popups
  final Set<String> _shownPopups = {};

  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if we have a popup for this screen
    if (_mockPopups.containsKey(screenName)) {
      final popup = _mockPopups[screenName]!;
      
      // For showOnce popups, check if already shown
      if (popup.showOnce && _shownPopups.contains(popup.id)) {
        return PopupApiResponse(hasPopup: false);
      }

      // For expired popups, don't show
      if (popup.isExpired) {
        return PopupApiResponse(hasPopup: false);
      }

      print('Mock API: Found popup for screen $screenName');
      return PopupApiResponse(hasPopup: true, popup: popup);
    }

    print('Mock API: No popup found for screen $screenName');
    return PopupApiResponse(hasPopup: false);
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    print('Mock API: Submitted response for popup ${popupResponse.popupId}');
    print('Mock API: Response data: ${popupResponse.responses}');
    // Log the full JSON response
    // print('Mock API: Response JSON: ${jsonEncode(popupResponse.toJson())}');
    
    // In a real implementation, you would send this to your backend
    return true;
  }

  @override
  Future<void> popupShown({
    required String popupId,
    String? userId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    print('Mock API: Popup $popupId shown to user $userId');
    // Track shown popups for showOnce functionality
    _shownPopups.add(popupId);
  }

  @override
  Future<void> popupDismissed({
    required String popupId,
    String? userId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    print('Mock API: Popup $popupId dismissed by user $userId');
  }

  @override
  Future<PopupConfig?> getPopupById(String popupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find popup by ID
    for (var popup in _mockPopups.values) {
      if (popup.id == popupId) {
        print('Mock API: Found popup by ID $popupId');
        return popup;
      }
    }

    print('Mock API: No popup found with ID $popupId');
    return null;
  }

  // Method to reset mock state for testing
  void resetMockState() {
    _shownPopups.clear();
    print('Mock API: Reset all mock state');
  }
}