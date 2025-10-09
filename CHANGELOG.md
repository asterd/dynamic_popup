## [1.0.7] - 2025-10-09

### Added
- **Enhanced Conditional Logic System**:
  - New `required-when-value` attribute to control required status based on another field's specific value
  - Support for three-tier conditional logic priority:
    1. `required-when-value` (highest priority) - Controls required status based on dependent field value
    2. `required-when-visible` (medium priority) - Controls required status based on visibility
    3. Default `required` attribute (lowest priority) - Static required status
  - Components can now be always visible but dynamically required based on other field values
  - Case-insensitive conditional logic evaluation for better user experience
- **Improved UI Feedback**:
  - Dynamic asterisk indicator that updates in real-time based on current required status
  - Visual required status changes are immediately reflected in all form components
- **Example App Enhancements**:
  - Separate, clear examples demonstrating both conditional visibility and conditional required status
  - Distinct use cases with different controller fields to avoid confusion
  - Comprehensive demonstration of all conditional logic features

### Changed
- **Conditional Logic Implementation**:
  - Refactored conditional logic evaluation to properly handle visibility vs required status
  - Fixed issue where `required-when-value` was not correctly evaluated against dependent field values
  - Improved component factory to correctly propagate dynamic required status to UI components
- **Component Rendering**:
  - Components now rebuild with updated required status when dependent fields change
  - Dynamic required status is properly passed from widget to individual components
- **Documentation**:
  - Comprehensive documentation for all conditional logic features and attributes
  - Clear examples showing proper usage of `depends-on`, `when-value`, `required-when-value`, and `required-when-visible`

## [1.0.6]

### Changed
- Fix issue where popup state was not persisted correctly

## [1.0.5]

### Added
- Optional lifecycle event hooks in repository interface (`popupShown`, `popupDismissed`)
- Enhanced visual feedback for form validation with red-themed header border
- Automatic scrolling to first invalid field when validation fails

### Changed
- Improved popup state management for `showOnce` popups to prevent reopening
- Snackbar error messages now use red color scheme for better visibility
- Repository interface extended with optional methods while maintaining backward compatibility
- Form validation now scrolls to first invalid field and highlights only the header instead of entire popup

## [1.0.4]

### Added
- Support for conditional required status in addition to conditional visibility
- New `required-when-visible` attribute for components to control required status based on visibility
- Case-insensitive conditional logic evaluation for better user experience
- Comprehensive documentation for conditional logic features
- New examples demonstrating both conditional visibility and conditional required status

### Fixed
- Fixed issue where `showOnce` popups would reappear after being completed or dismissed
- Enhanced form validation feedback with both local component and global popup highlighting
- Fixed popup state persistence by implementing proper loading from local storage