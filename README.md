# Dynamic Popup

A flexible and customizable dynamic popup system for Flutter with markdown support and interactive components.

## Features

- **Configurable popups** from backend APIs
- **Markdown parser** with support for dynamic component placeholders
- **Interactive components**: RadioButton, Checkbox, TextArea, TextField, Dropdown
- **Automatic validation** of required fields
- **Persistent state management** (show once, completed/dismissed)
- **Blocking and non-blocking** popup behaviors
- **Easy to customize** and extend
- **No dependency on GetX** - works with any Flutter app
- **Minimal API requirements** - only two endpoints required

## 🚀 Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  dynamic_popup: ^1.0.2
```

Then run:

```bash
flutter pub get
```

**Note**: The `http` package is only required if you use the example implementations. The core library does not depend on `http`.

## 📱 Popup Types

### 1. Non-blocking Popup
- User can close without completing
- Ideal for information, optional surveys, feature discovery

### 2. Blocking Popup  
- User must complete to continue
- Ideal for terms of service, privacy policy, required data

## 🛠 Supported Components

### RadioButton
```markdown
[RADIOBUTTON:required:component_id:Label:Option1,Option2,Option3]
```

### Checkbox (single/multiple)
```markdown
[CHECKBOX:optional:component_id:Label:Option1,Option2,Option3]
```

### TextArea
```markdown
[TEXTAREA:required:component_id:Label:Placeholder text]
```

### TextField
```markdown
[TEXTFIELD:optional:component_id:Label:Placeholder text]
```

### Dropdown
```markdown
[DROPDOWN:required:component_id:Label:Option1,Option2,Option3]
```

## 🔧 Placeholder Syntax

```
[COMPONENT_TYPE:required/optional:component_id:label:options/placeholder]
```

**Parameters:**
- `COMPONENT_TYPE`: Component type (RADIOBUTTON, CHECKBOX, etc.)
- `required/optional`: Whether the field is required
- `component_id`: Unique component ID
- `label`: Label shown to user
- `options/placeholder`: Options (for radio/checkbox/dropdown) or placeholder (for text)

## 💻 Usage

### Setup Service

```dart
import 'package:dynamic_popup/dynamic_popup.dart';

// Create a repository that implements your API calls
class MyPopupRepository extends BaseDynamicPopupRepository {
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // Implement your API call here
    // Only these two methods are required
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // Implement your API call here
    // Only these two methods are required
  }
}

// In your app initialization (e.g., in initState of your main widget)
final popupService = DynamicPopupService(
  repository: MyPopupRepository(),
);
popupService.init(); // Initialize the service
```

### Show Manual Popup

```dart
// Show specific popup by ID
await popupService.showPopupById('privacy_update_2024', context: context);

// Check for and show popup for a screen
await popupService.checkAndShowPopup(
  screenName: 'home_screen',
  context: context,
);

// Reset state for testing
await popupService.resetPopupState('privacy_update_2024');

// Reset all states
popupService.resetAllPopupStates();
```

### Using the Test Page

```dart
import 'package:dynamic_popup/dynamic_popup.dart';

// Navigate to test page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DynamicPopupTestPage()),
);
```

### Manual Popup Display

```dart
// Test specific component
final config = PopupConfig(
  id: 'test_popup',
  title: 'Test',
  markdownContent: '[RADIOBUTTON:required:test:Test?:Yes,No]',
  isBlocking: false,
);

showDialog(
  context: context,
  builder: (BuildContext context) {
    return DynamicPopupWidget(
      config: config,
      onCompleted: (response) => print('Response: ${response.responses}'),
    );
  },
);
```

## 🔌 Custom API Integration

The package is designed to work with any backend API with minimal requirements. Here's how to integrate with your custom API:

### 1. Minimal Implementation (Only 2 Required Methods)

```dart
import 'package:dynamic_popup/dynamic_popup.dart';

class MySimplePopupRepository extends BaseDynamicPopupRepository {
  @override
  Future<PopupApiResponse?> checkForPopup({
    required String screenName,
    String? userId,
  }) async {
    // Only implement these two required methods
    // All other methods are optional
  }

  @override
  Future<bool> submitPopupResponse({
    required PopupResponse popupResponse,
  }) async {
    // Only implement these two required methods
    // All other methods are optional
  }
}
```

### 2. Direct Usage Without Service

```dart
// Fetch popup config from your API directly
final popupConfig = await MyApiService.getPopupForScreen('home_screen');

if (popupConfig != null) {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return DynamicPopupWidget(
        config: popupConfig,
        onCompleted: (response) async {
          // Submit response to your API directly
          await MyApiService.submitResponse(response);
          Navigator.of(context).pop();
        },
      );
    },
  );
}
```

## 🧪 Testing

### Test Page
Run `DynamicPopupTestPage` to test all components:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DynamicPopupTestPage()),
);
```

## 📋 Complete Examples

### Privacy Policy Popup
```markdown
# Privacy Policy Update

Our privacy policy has been updated. Please review and confirm your preferences.

## Required Consent
[RADIOBUTTON:required:privacy_accept:Do you accept the new privacy policy?:Accept,Decline]

## Data Usage (Optional)
[CHECKBOX:optional:data_usage:What data can we use?:Analytics,Marketing,Performance,Crash Reports]

## Feedback
[TEXTAREA:optional:feedback:Comments or questions?:Share your thoughts...]

**Thank you for your attention.**
```

### Complete Survey
```markdown  
# Satisfaction Survey

Help us improve the app by completing this brief survey.

[TEXTFIELD:required:name:Full Name:Enter your name]

[DROPDOWN:required:frequency:Usage Frequency:Daily,Weekly,Monthly,Occasional]

[CHECKBOX:required:features:Which features do you use?:Restaurant,Special Sales,PCM,Snack Bar]

[TEXTAREA:required:suggestions:Improvement suggestions:Describe your ideas...]

[RADIOBUTTON:required:recommend:Would you recommend the app?:Definitely,Probably,Not Sure,Probably Not,Definitely Not]
```

## 🏗 Architecture

### File Structure
```
lib/
├── src/
│   ├── data/
│   │   ├── model/
│   │   │   ├── popup_config.dart
│   │   │   ├── dynamic_component.dart
│   │   │   └── popup_models.dart
│   │   └── repository/
│   │       ├── dynamic_popup_repository.dart
│   │       └── base_dynamic_popup_repository.dart
│   ├── parser/
│   │   └── markdown_dynamic_parser.dart
│   ├── service/
│   │   └── dynamic_popup_service.dart
│   ├── ui/
│   │   ├── components/
│   │   │   ├── dynamic_radio_button.dart
│   │   │   ├── dynamic_checkbox.dart
│   │   │   ├── dynamic_text_area.dart
│   │   │   ├── dynamic_text_field.dart
│   │   │   ├── dynamic_dropdown.dart
│   │   │   └── dynamic_component_factory.dart
│   │   └── dynamic_popup_widget.dart
│   └── test/
│       └── dynamic_popup_test_page.dart
└── dynamic_popup.dart
```

## 🔒 Security and Privacy

- All data is validated client-side
- Responses are sent in secure JSON format
- Local storage is encrypted for popup states
- No sensitive data stored permanently

## 🎨 Customization

### Themes and Styles
The system uses the current app theme. To customize:

```dart
// In dynamic_popup_widget.dart, modify colors:
primaryColor: Theme.of(context).primaryColor,
errorColor: Colors.red.shade600,
backgroundColor: Colors.grey.shade50,
```

### Custom Components
Add new components by extending `DynamicComponentFactory`:

```dart
case DynamicComponentType.newType:
  return NewCustomWidget(/* ... */);
```

## 🚨 Troubleshooting

### Popup doesn't appear
- Verify service is initialized
- Check API logs for errors
- Verify target screen is correct

### Parsing errors
- Check placeholder markdown syntax
- Verify all components have unique IDs
- Ensure options don't contain special characters

### Validation issues
- Check that required fields have values
- Verify data types are correct
- Test with simple popups first

## 📝 Changelog

### v1.0.2
- Removed http dependency from core library (moved to example project only)
- Removed unused DefaultDynamicPopupRepository from core library
- Added .pubignore file to prevent publishing unnecessary files
- Updated documentation to clarify dependency requirements
- Improved package structure for pub.dev publishing

### v1.0.1
- Simplified repository pattern by reducing required methods from 7 to 3
- Removed complex optional methods (markPopupAsShown, markPopupAsDismissed) for easier implementation
- Streamlined example code by removing redundant buttons and simplifying demonstrations
- Improved documentation with clearer, more concise instructions
- Added JSON logging in example apps for better debugging of popup responses
- Enhanced snackbar colors in examples for better readability and user experience
- Fixed undefined variable error in API integration example
- Removed unnecessary http dependency from core library (now only in example)
- Removed unused DefaultDynamicPopupRepository from core library
- Maintained all core functionality while reducing complexity

### v1.0.0
- ✅ Base dynamic popup system
- ✅ Markdown parser with placeholders
- ✅ Interactive UI components  
- ✅ API repository and service
- ✅ Controller integration
- ✅ Testing system
- ✅ Removed GetX dependency for better compatibility
- ✅ Simplified API requirements (only 2 endpoints required)

## 📞 Support

For questions or issues with the dynamic popup system, please open an issue on GitHub.