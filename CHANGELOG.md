## 1.0.2

- Removed http dependency from core library (moved to example project only)
- Removed unused DefaultDynamicPopupRepository from core library
- Added .pubignore file to prevent publishing unnecessary files
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