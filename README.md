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
- **Custom slots support** - add custom titles, footers, and action buttons
- **Smart scrolling** - automatically shows scroll buttons for long content

## 🚀 Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  dynamic_popup: ^1.0.3
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
```
<!-- New HTML-like syntax with custom initiator -->
:::dc<radiobutton id="component_id" required label="Label">
  <option id="opt1">Option1</option>
  <option id="opt2">Option2</option>
  <option id="opt3">Option3</option>
</radiobutton>dc:::
```

### Checkbox (single/multiple)
```
<!-- New HTML-like syntax with custom initiator -->
:::dc<checkbox id="component_id" label="Label">
  <option id="opt1">Option1</option>
  <option id="opt2">Option2</option>
  <option id="opt3">Option3</option>
</checkbox>dc:::
```

### TextArea
```
<!-- New HTML-like syntax with custom initiator -->
:::dc<textarea id="component_id" required label="Label" placeholder="Placeholder text" />dc:::
```

### TextField
```
<!-- New HTML-like syntax with custom initiator -->
:::dc<textfield id="component_id" label="Label" placeholder="Placeholder text" />dc:::
```

### Dropdown
```
<!-- New HTML-like syntax with custom initiator -->
:::dc<dropdown id="component_id" required label="Label">
  <option id="opt1">Option1</option>
  <option id="opt2">Option2</option>
  <option id="opt3">Option3</option>
</dropdown>dc:::
```

## 🔧 Placeholder Syntax

### New Syntax (HTML-like with Named Attributes and Custom Initiator)
```
:::dc<component_type id="component_id" required label="Label" placeholder="Placeholder" />dc:::
```

**Custom Initiator:** `:::dc<` and `>dc:::` - This prevents conflicts with regular HTML tags in markdown content.

**Multiline Support:** The syntax supports newlines and spaces between the initiator and terminator:
```
:::dc
<component_type id="component_id" required label="Label">
  <option id="opt1">Option1</option>
</component_type>
dc:::
```

**Attributes:**
- `id`: Unique component ID (required)
- `required`: Presence indicates the field is required (optional)
- `label`: Label shown to user (required)
- `placeholder`: Placeholder text for text inputs (optional)
- `default`: Default value (optional)

**Container Components with Option IDs:**
For components with options (RadioButton, Checkbox, Dropdown), use container syntax with option IDs:
```html
:::dc<component_type id="component_id" required label="Label">
  <option id="option_id_1">Option 1</option>
  <option id="option_id_2">Option 2</option>
</component_type>dc:::
```

**Benefits of Option IDs:**
- Send option IDs instead of text to the backend
- Language-independent option identification
- Easier to maintain when option text changes

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

### Using Custom Slots

```dart
// Add custom title, footer, and action buttons
final config = PopupConfig(
  id: 'custom_popup',
  title: 'Custom Popup',
  markdownContent: '''
## Welcome!

:::dc<textfield id="name" label="Your Name" placeholder="Enter your name" />dc:::
  ''',
  isBlocking: false,
);

showDialog(
  context: context,
  builder: (BuildContext context) {
    return DynamicPopupWidget(
      config: config,
      customTitle: const Text('Custom Title', style: TextStyle(color: Colors.white, fontSize: 24)),
      customFooter: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('This is a custom footer', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      customActions: [
        TextButton(
          onPressed: () {
            // Custom action
            print('Custom button pressed');
          },
          child: const Text('Custom Action'),
        ),
      ],
      onCompleted: (response) => print('Response: ${response.responses}'),
    );
  },
);
```

### Manual Popup Display

```dart
// Test specific component
final config = PopupConfig(
  id: 'test_popup',
  title: 'Test',
  markdownContent: '''
:::dc<radiobutton id="test" required label="Test?">
  <option id="yes">Yes</option>
  <option id="no">No</option>
</radiobutton>dc:::
  ''',
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
The example app now includes a comprehensive test page with all popup types and a documentation screen.

## 📋 Complete Examples

### Privacy Policy Popup
```
# Privacy Policy Update

Our privacy policy has been updated. Please review and confirm your preferences.

## Required Consent
:::dc<radiobutton id="privacy_accept" required label="Do you accept the new privacy policy?">
  <option id="accept">Accept</option>
  <option id="decline">Decline</option>
</radiobutton>dc:::

## Data Usage (Optional)
:::dc<checkbox id="data_usage" label="What data can we use?">
  <option id="analytics">Analytics</option>
  <option id="marketing">Marketing</option>
  <option id="performance">Performance</option>
  <option id="crash">Crash Reports</option>
</checkbox>dc:::

## Feedback
:::dc<textarea id="feedback" label="Comments or questions?" placeholder="Share your thoughts..." />dc:::

**Thank you for your attention.**
```

### Complete Survey
```
# Satisfaction Survey

Help us improve the app by completing this brief survey.

:::dc<textfield id="name" required label="Full Name" placeholder="Enter your name" />dc:::

:::dc<dropdown id="frequency" required label="Usage Frequency">
  <option id="daily">Daily</option>
  <option id="weekly">Weekly</option>
  <option id="monthly">Monthly</option>
  <option id="occasional">Occasional</option>
</dropdown>dc:::

:::dc<checkbox id="features" required label="Which features do you use?">
  <option id="restaurant">Restaurant</option>
  <option id="sales">Special Sales</option>
  <option id="pcm">PCM</option>
  <option id="snack">Snack Bar</option>
</checkbox>dc:::

:::dc<textarea id="suggestions" required label="Improvement suggestions" placeholder="Describe your ideas..." />dc:::

:::dc<radiobutton id="recommend" required label="Would you recommend the app?">
  <option id="definitely">Definitely</option>
  <option id="probably">Probably</option>
  <option id="not_sure">Not Sure</option>
  <option id="probably_not">Probably Not</option>
  <option id="definitely_not">Definitely Not</option>
</radiobutton>dc:::
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

### [1.0.3] - 2025-09-29

### Added
- Support for option IDs in radio buttons, checkboxes, and dropdowns
- Smart scrolling for long content in popups
- Support for multiline syntax with newlines and spaces in component definitions
- Custom slots support for titles, footers, and action buttons
- Dedicated examples/documentation screen in the example app
- View Markdown button in example popups

### Changed
- Improved markdown syntax from positional parameters to HTML-like syntax
- Updated component initiator from `:::` to `:::dc<component>dc:::` for better identification
- Removed support for old positional parameter syntax
- Updated all examples to use new HTML-like syntax with option IDs
- Enhanced UI components to send option IDs instead of text values in responses
- Consolidated test interface into main example screen
- Improved dialog dismissal handling to prevent overlay issues

### Fixed
- Ensured option IDs are properly used in popup responses instead of text values
- Fixed overlay persistence issue when dismissing non-required popups

### 1.0.2

- Removed http dependency from core library (moved to example project only)
- Removed unused DefaultDynamicPopupRepository from core library
- Added .pubignore file to prevent publishing unnecessary files
- Added LICENSE file with MIT license
- Added CONTRIBUTING.md with contribution guidelines
- Added CODE_OF_CONDUCT.md with community standards
- Fixed flutter analyze issues:
  - Removed unused local variable in dynamic_popup_service.dart
  - Removed unnecessary imports in dynamic_popup_widget.dart
  - Updated deprecated onPopInvoked to onPopInvokedWithResult
  - Updated deprecated value parameter to initialValue in dropdown
- Updated documentation to clarify dependency requirements
- Improved package structure for pub.dev publishing

### 1.0.1
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

### 1.0.0
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