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
    this.placeholder,
    this.defaultValue,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.validation,
    this.metadata,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'label': label,
      'isRequired': isRequired,
      'options': options,
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
