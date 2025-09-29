# Dynamic Popup Example App

This example app demonstrates how to use the `dynamic_popup` package to create dynamic, configurable popups in Flutter applications.

## Features Demonstrated

- Basic popup implementation with different types (blocking/non-blocking)
- Custom API integration examples
- Mock repository implementation for testing
- JSON response logging for debugging
- Proper snackbar styling for user feedback

## Getting Started

1. Clone or download this repository
2. Navigate to the `example` directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the example app

## Example Usage

The example app showcases several ways to use the dynamic popup system:

### 1. Manual Popup Display
Create and display popups manually with custom content:

```dart
final config = PopupConfig(
  id: 'example_popup',
  title: 'Example Popup',
  markdownContent: '''
## Welcome!

:::dc<radiobutton id="enjoying" required label="Are you enjoying the app?">
  <option id="yes">Yes</option>
  <option id="no">No</option>
  <option id="neutral">Neutral</option>
</radiobutton>dc:::

:::dc<textarea id="feedback" label="Feedback" placeholder="Any suggestions?" />dc:::
  ''',
  isBlocking: false,
  showOnce: true,
);

showDialog(
  context: context,
  builder: (BuildContext context) {
    return DynamicPopupWidget(
      config: config,
      onCompleted: (response) {
        print('Popup response: ${response.responses}');
      },
    );
  },
);
```

### 2. Service-Based Popup Management
Use the `DynamicPopupService` for more advanced popup management:

```dart
// Create a repository that implements your API calls
class MyPopupRepository extends BaseDynamicPopupRepository {
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // Implement your API call here
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // Implement your API call here
  }
}

// Initialize the service
final popupService = DynamicPopupService(
  repository: MyPopupRepository(),
);
popupService.init();

// Check for and show popups automatically
await popupService.checkAndShowPopup(
  screenName: 'home_screen',
  context: context,
);
```

## Custom API Integration

The example includes a complete implementation of a custom API repository that shows how to integrate with your own backend services. It demonstrates:

- Making HTTP requests to fetch popup configurations
- Submitting user responses to your API
- Handling errors and edge cases
- Proper JSON serialization

## Screenshots

![Example App Home](screenshots/home.png)
![Non-blocking Popup](screenshots/non_blocking.png)
![Blocking Popup](screenshots/blocking.png)

## Learn More

For detailed documentation on the `dynamic_popup` package, see the [main README](../README.md).