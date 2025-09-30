## [1.0.4] - 2025-09-30

### Added
- Optional lifecycle event hooks in repository interface (`popupShown`, `popupDismissed`)
- Enhanced visual feedback for form validation with red-themed error indicators
- Global popup border highlighting for validation errors
- Header border highlighting for improved error visibility

### Changed
- Improved popup state management for `showOnce` popups to prevent reopening
- Snackbar error messages now use red color scheme for better visibility
- Repository interface extended with optional methods while maintaining backward compatibility

### Fixed
- Fixed issue where `showOnce` popups would reappear after being completed or dismissed
- Enhanced form validation feedback with both local component and global popup highlighting

## [1.0.3] - 2025-09-29

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

## 1.0.2

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

## 1.0.1

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

## 1.0.0

- Initial release of the dynamic popup system
- Support for configurable popups from backend APIs
- Markdown parser with dynamic component placeholders
- Interactive UI components: RadioButton, Checkbox, TextArea, TextField, Dropdown
- Automatic validation of required fields
- Persistent state management (show once, completed/dismissed)
- Support for both blocking and non-blocking popup behaviors
- Smooth animations and modern design
- Offline support with local storage
- Comprehensive test page for validation
- Detailed documentation and examples