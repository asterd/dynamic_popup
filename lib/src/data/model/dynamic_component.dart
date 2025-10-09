// Enum for supported dynamic component types
enum DynamicComponentType {
  radioButton,
  checkbox,
  textArea,
  textField,
  dropdown,
}

// Enum for content types in parsed markdown
enum ContentType {
  markdown,
  component,
}

// Model for content elements in parsed markdown
class ContentElement {
  final ContentType type;
  final String? markdownContent;
  final DynamicComponent? component;

  ContentElement.markdown(this.markdownContent) : 
    type = ContentType.markdown,
    component = null;

  ContentElement.component(this.component) : 
    type = ContentType.component,
    markdownContent = null;
}

// Model for parsed markdown content
class ParsedMarkdownContent {
  final List<ContentElement> contentFlow;
  final List<DynamicComponent> components;

  ParsedMarkdownContent({
    required this.contentFlow,
    required this.components,
  });
}

// Model for component candidate during parsing
class ComponentCandidate {
  final int position;
  final int endPosition;
  final RegExpMatch match;
  final bool isNewSyntax;

  ComponentCandidate({
    required this.position,
    required this.endPosition,
    required this.match,
    required this.isNewSyntax,
  });
}

// Model for dynamic component configuration
class DynamicComponent {
  final String id;
  final DynamicComponentType type;
  final String label;
  final bool isRequired;
  final List<String>? options; // For radio button, checkbox multiple, dropdown
  final List<OptionData>? optionData; // Extended option data with IDs
  final String? placeholder;
  final String? defaultValue;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final Map<String, dynamic>? validation;
  final Map<String, dynamic>? metadata;
  final ConditionalLogic? conditionalLogic; // For conditional display/validation

  DynamicComponent({
    required this.id,
    required this.type,
    required this.label,
    this.isRequired = false,
    this.options,
    this.optionData,
    this.placeholder,
    this.defaultValue,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.validation,
    this.metadata,
    this.conditionalLogic,
  });

  // Add copyWith method for creating modified copies of the component
  DynamicComponent copyWith({
    String? id,
    DynamicComponentType? type,
    String? label,
    bool? isRequired,
    List<String>? options,
    List<OptionData>? optionData,
    String? placeholder,
    String? defaultValue,
    int? maxLength,
    int? minLines,
    int? maxLines,
    Map<String, dynamic>? validation,
    Map<String, dynamic>? metadata,
    ConditionalLogic? conditionalLogic,
  }) {
    return DynamicComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      optionData: optionData ?? this.optionData,
      placeholder: placeholder ?? this.placeholder,
      defaultValue: defaultValue ?? this.defaultValue,
      maxLength: maxLength ?? this.maxLength,
      minLines: minLines ?? this.minLines,
      maxLines: maxLines ?? this.maxLines,
      validation: validation ?? this.validation,
      metadata: metadata ?? this.metadata,
      conditionalLogic: conditionalLogic ?? this.conditionalLogic,
    );
  }

  // Comment out or remove the old factory method since we no longer support the old syntax
  /*
  factory DynamicComponent.fromPlaceholder(String placeholder) {
    // Parse placeholder of type: [RADIOBUTTON:required:id:label:option1,option2,option3]
    final parts = placeholder.substring(1, placeholder.length - 1).split(':');
    
    if (parts.isEmpty) throw ArgumentError('Invalid placeholder format');
    
    final typeStr = parts[0].toLowerCase();
    final isRequired = parts.length > 1 && parts[1].toLowerCase() == 'required';
    final id = parts.length > 2 ? parts[2] : 'component_${DateTime.now().millisecondsSinceEpoch}';
    final label = parts.length > 3 ? parts[3] : 'Field';
    
    DynamicComponentType type;
    switch (typeStr) {
      case 'radiobutton':
        type = DynamicComponentType.radioButton;
        break;
      case 'checkbox':
        type = DynamicComponentType.checkbox;
        break;
      case 'textarea':
        type = DynamicComponentType.textArea;
        break;
      case 'textfield':
        type = DynamicComponentType.textField;
        break;
      case 'dropdown':
        type = DynamicComponentType.dropdown;
        break;
      default:
        throw ArgumentError('Unsupported component type: $typeStr');
    }

    List<String>? options;
    if (parts.length > 4 && (type == DynamicComponentType.radioButton || 
                            type == DynamicComponentType.checkbox || 
                            type == DynamicComponentType.dropdown)) {
      options = parts[4].split(',').map((e) => e.trim()).toList();
    }

    return DynamicComponent(
      id: id,
      type: type,
      label: label,
      isRequired: isRequired,
      options: options,
      placeholder: type == DynamicComponentType.textArea || type == DynamicComponentType.textField 
          ? (parts.length > 4 ? parts[4] : null)
          : null,
      maxLines: type == DynamicComponentType.textArea ? 4 : 1,
      minLines: type == DynamicComponentType.textArea ? 2 : 1,
    );
  }
  */

  // New factory method to create components from HTML-like tags
  factory DynamicComponent.fromHtmlTag(String tagType, Map<String, String> attributeMap, List<OptionData>? options) {
    // The attributeMap is already parsed, so we can use it directly
    final required = attributeMap.containsKey('required');
    
    final id = attributeMap['id'] ?? 'component_${DateTime.now().millisecondsSinceEpoch}';
    final label = attributeMap['label'] ?? 'Field';
    final placeholder = attributeMap['placeholder'];
    final defaultValue = attributeMap['default'];
    
    // Parse conditional logic if present
    ConditionalLogic? conditionalLogic;
    print('Checking for conditional logic. Attribute map keys: ${attributeMap.keys}');
    if (attributeMap.containsKey('depends-on')) {
      print('Creating ConditionalLogic for component with id: ${attributeMap['id']}, depends-on: ${attributeMap['depends-on']}');
      
      // Parse visibility condition (when-value or visible-when-value)
      String? visibilityValue;
      if (attributeMap.containsKey('when-value')) {
        visibilityValue = attributeMap['when-value'];
      } else if (attributeMap.containsKey('visible-when-value')) {
        visibilityValue = attributeMap['visible-when-value'];
      }
      
      // Parse required-when-value attribute (this is the value that makes the field required)
      String? requiredWhenValue;
      if (attributeMap.containsKey('required-when-value')) {
        requiredWhenValue = attributeMap['required-when-value'];
      }
      
      // Create conditional logic
      conditionalLogic = ConditionalLogic(
        dependsOn: attributeMap['depends-on']!,
        condition: attributeMap['condition'] ?? 'equals',
        value: visibilityValue, // Use visibility value for visibility checks
        disableWhenHidden: attributeMap['disable-when-hidden'] != 'false',
        requiredWhenVisible: null, // Not used anymore
        requiredWhenValue: requiredWhenValue, // The value that makes the field required
      );
      
      print('Created ConditionalLogic: $conditionalLogic');
    } else {
      print('No conditional logic for component with id: ${attributeMap['id']}');
    }
    
    DynamicComponentType type;
    switch (tagType.toLowerCase()) {
      case 'radiobutton':
        type = DynamicComponentType.radioButton;
        break;
      case 'checkbox':
        type = DynamicComponentType.checkbox;
        break;
      case 'textarea':
        type = DynamicComponentType.textArea;
        break;
      case 'textfield':
        type = DynamicComponentType.textField;
        break;
      case 'dropdown':
        type = DynamicComponentType.dropdown;
        break;
      default:
        throw ArgumentError('Unsupported component type: $tagType');
    }

    // Extract just the text values for backward compatibility
    final optionTexts = options?.map((o) => o.text).toList();

    return DynamicComponent(
      id: id,
      type: type,
      label: label,
      isRequired: required,
      options: optionTexts,
      optionData: options,
      placeholder: placeholder,
      defaultValue: defaultValue,
      maxLines: type == DynamicComponentType.textArea ? 4 : 1,
      minLines: type == DynamicComponentType.textArea ? 2 : 1,
      conditionalLogic: conditionalLogic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'label': label,
      'isRequired': isRequired,
      'options': options,
      'optionData': optionData?.map((o) => {'id': o.id, 'text': o.text}).toList(),
      'placeholder': placeholder,
      'defaultValue': defaultValue,
      'maxLength': maxLength,
      'minLines': minLines,
      'maxLines': maxLines,
      'validation': validation,
      'metadata': metadata,
      'conditionalLogic': conditionalLogic?.toJson(),
    };
  }
}

// Helper class for option data with ID support
class OptionData {
  final String? id;
  final String text;
  
  OptionData({required this.id, required this.text});
  
  @override
  String toString() => id != null ? '$text|$id' : text;
}

// Class for conditional logic between components
class ConditionalLogic {
  final String dependsOn; // ID of the component this depends on
  final String? condition; // Condition type (equals, notEquals, contains, etc.)
  final dynamic value; // Value to compare against for visibility
  final bool disableWhenHidden; // Whether to disable validation when hidden
  final bool? requiredWhenVisible; // Whether the component should be required when visible (null means use component's default)
  final String? requiredWhenValue; // The value of the dependsOn field that makes this component required (null means not conditional)
  
  ConditionalLogic({
    required this.dependsOn,
    this.condition = 'equals',
    required this.value,
    this.disableWhenHidden = true,
    this.requiredWhenVisible,
    this.requiredWhenValue,
  });
  
  @override
  String toString() {
    return 'ConditionalLogic{dependsOn: $dependsOn, condition: $condition, value: $value, disableWhenHidden: $disableWhenHidden, requiredWhenVisible: $requiredWhenVisible, requiredWhenValue: $requiredWhenValue}';
  }
  
  // Check if the visibility condition is met
  bool isVisibilityMet(dynamic dependentValue) {
    // If value is null, this means no visibility condition was set, so return true (always visible)
    if (value == null) return true;
    
    if (dependentValue == null) return false;
    
    switch (condition) {
      case 'equals':
        return dependentValue.toString().toLowerCase() == value.toString().toLowerCase();
      case 'notEquals':
        return dependentValue.toString().toLowerCase() != value.toString().toLowerCase();
      case 'contains':
        if (dependentValue is List) {
          return dependentValue.any((item) => item.toString().toLowerCase() == value.toString().toLowerCase());
        } else {
          return dependentValue.toString().contains(value.toString());
        }
      case 'notContains':
        if (dependentValue is List) {
          return !dependentValue.any((item) => item.toString().toLowerCase() == value.toString().toLowerCase());
        } else {
          return !dependentValue.toString().contains(value.toString());
        }
      default:
        // Default to equals condition
        return dependentValue.toString().toLowerCase() == value.toString().toLowerCase();
    }
  }
  
  // Check if the required condition is met
  bool isRequiredMet(dynamic dependentValue) {
    // If requiredWhenValue is null, this means no required condition was set
    if (requiredWhenValue == null) return false;
    
    if (dependentValue == null) return false;
    
    // Check if the dependent value matches the requiredWhenValue
    switch (condition) {
      case 'equals':
        return dependentValue.toString().toLowerCase() == requiredWhenValue.toString().toLowerCase();
      case 'notEquals':
        return dependentValue.toString().toLowerCase() != requiredWhenValue.toString().toLowerCase();
      case 'contains':
        if (dependentValue is List) {
          return dependentValue.any((item) => item.toString().toLowerCase() == requiredWhenValue.toString().toLowerCase());
        } else {
          return dependentValue.toString().contains(requiredWhenValue.toString());
        }
      case 'notContains':
        if (dependentValue is List) {
          return !dependentValue.any((item) => item.toString().toLowerCase() == requiredWhenValue.toString().toLowerCase());
        } else {
          return !dependentValue.toString().contains(requiredWhenValue.toString());
        }
      default:
        // Default to equals condition
        return dependentValue.toString().toLowerCase() == requiredWhenValue.toString().toLowerCase();
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'dependsOn': dependsOn,
      'condition': condition,
      'value': value,
      'disableWhenHidden': disableWhenHidden,
      'requiredWhenVisible': requiredWhenVisible,
      'requiredWhenValue': requiredWhenValue,
    };
  }
}