import 'package:flutter/material.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';
import 'package:dynamic_popup/src/ui/components/dynamic_radio_button.dart';
import 'package:dynamic_popup/src/ui/components/dynamic_checkbox.dart';
import 'package:dynamic_popup/src/ui/components/dynamic_text_area.dart';
import 'package:dynamic_popup/src/ui/components/dynamic_text_field.dart';
import 'package:dynamic_popup/src/ui/components/dynamic_dropdown.dart';

/// Factory for creating dynamic UI components
class DynamicComponentFactory {
  /// Create a widget for a dynamic component
  static Widget createComponent({
    required DynamicComponent component,
    required Function(String componentId, dynamic value) onChanged,
    dynamic initialValue,
    bool hasError = false,
    bool isRequired = false, // Add dynamic required status parameter
  }) {
    // Create a copy of the component with the dynamic required status
    final dynamicComponent = component.copyWith(isRequired: isRequired);
        
    switch (dynamicComponent.type) {
      case DynamicComponentType.radioButton:
        return DynamicRadioButton(
          component: dynamicComponent,
          onChanged: onChanged,
          initialValue: initialValue,
          hasError: hasError,
        );
      case DynamicComponentType.checkbox:
        return DynamicCheckbox(
          component: dynamicComponent,
          onChanged: onChanged,
          initialValue: initialValue,
          hasError: hasError,
        );
      case DynamicComponentType.textArea:
        return DynamicTextArea(
          component: dynamicComponent,
          onChanged: onChanged,
          initialValue: initialValue,
          hasError: hasError,
        );
      case DynamicComponentType.textField:
        return DynamicTextField(
          component: dynamicComponent,
          onChanged: onChanged,
          initialValue: initialValue,
          hasError: hasError,
        );
      case DynamicComponentType.dropdown:
        return DynamicDropdown(
          component: dynamicComponent,
          onChanged: onChanged,
          initialValue: initialValue,
          hasError: hasError,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Get default value for a component
  static dynamic getDefaultValue(DynamicComponent component) {
    switch (component.type) {
      case DynamicComponentType.radioButton:
        return null;
      case DynamicComponentType.checkbox:
        return <String>[];
      case DynamicComponentType.textArea:
        return '';
      case DynamicComponentType.textField:
        return '';
      case DynamicComponentType.dropdown:
        return null;
      default:
        return null;
    }
  }

  /// Validate a component
  static bool validateComponent(DynamicComponent component, dynamic value) {
    // If not required, it's always valid
    if (!component.isRequired) return true;

    // Check based on component type
    switch (component.type) {
      case DynamicComponentType.radioButton:
        return value != null && value.toString().isNotEmpty;
      case DynamicComponentType.checkbox:
        // For checkbox, value should be a list
        if (value is List) {
          return value.isNotEmpty;
        }
        return false;
      case DynamicComponentType.textArea:
      case DynamicComponentType.textField:
        return value != null && value.toString().trim().isNotEmpty;
      case DynamicComponentType.dropdown:
        return value != null && value.toString().isNotEmpty;
      default:
        return true;
    }
  }

  /// Prepare value for API submission
  static dynamic prepareValueForApi(DynamicComponent component, dynamic value) {
    // For most components, we can send the value as-is
    // For checkboxes, we might want to join the list into a comma-separated string
    if (component.type == DynamicComponentType.checkbox && value is List) {
      return value.join(',');
    }
    
    return value;
  }
}