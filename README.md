# Dynamic Popup

A flexible and customizable dynamic popup system for Flutter with markdown support and interactive components.

## Features

- **Configurable popups** from backend APIs
- **Markdown parser** with support for dynamic component placeholders
- **Interactive components**: RadioButton, Checkbox, TextArea, TextField, Dropdown
- **Automatic validation** of required fields
- **Persistent state management** (show once, completed/dismissed)
- **Blocking and non-blocking** popup behaviors
- **Smooth animations** and modern design
- **Offline support** with local storage
- **Easy to customize** and extend

## 🚀 Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  dynamic_popup: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📱 Popup Types

### 1. Non-blocking Popup
- User can close without completing
- Ideal for information, optional surveys, feature discovery
- "Cancel" button available

### 2. Blocking Popup  
- User must complete to continue
- Ideal for terms of service, privacy policy, required data
- No close button

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

// In your app initialization
final popupService = Get.put(DynamicPopupService());
```

### Show Manual Popup

```dart
// Show specific popup by ID
await popupService.showPopupById('privacy_update_2024');

// Reset state for testing
await popupService.resetPopupState('privacy_update_2024');

// Reset all states
popupService.resetAllPopupStates();
```

### Using the Test Page

```dart
import 'package:dynamic_popup/dynamic_popup.dart';

// Navigate to test page
Get.to(() => const DynamicPopupTestPage());
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

Get.dialog(DynamicPopupWidget(
  config: config,
  onCompleted: (response) => print('Response: ${response.responses}'),
));
```

## 🧪 Testing

### Test Page
Run `DynamicPopupTestPage` to test all components:

```dart
Get.to(() => const DynamicPopupTestPage());
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
│   │       └── dynamic_popup_repository.dart
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
- Verify service is registered
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

### v1.0.0
- ✅ Base dynamic popup system
- ✅ Markdown parser with placeholders
- ✅ Interactive UI components  
- ✅ API repository and service
- ✅ Controller integration
- ✅ Testing system

## 📞 Support

For questions or issues with the dynamic popup system, please open an issue on GitHub.
