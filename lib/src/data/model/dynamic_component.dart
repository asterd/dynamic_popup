// Enum for supported dynamic component types
enum DynamicComponentType {
  radioButton,
  checkbox,
  textArea,
  textField,
  dropdown,
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
  });

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
  factory DynamicComponent.fromHtmlTag(String tagType, String attributes, List<OptionData>? options) {
    // Parse attributes from the format: key="value" key2="value2" or boolean attributes like "required"
    final attributeMap = <String, String>{};
    final attrRegex = RegExp(r'(\w+)="([^"]*)"');
    
    // First parse key="value" attributes
    for (final match in attrRegex.allMatches(attributes)) {
      attributeMap[match.group(1)!] = match.group(2)!;
    }
    
    // Then check for boolean attributes (present without values)
    final required = attributes.contains('required');
    
    final id = attributeMap['id'] ?? 'component_${DateTime.now().millisecondsSinceEpoch}';
    final label = attributeMap['label'] ?? 'Field';
    final placeholder = attributeMap['placeholder'];
    final defaultValue = attributeMap['default'];
    
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