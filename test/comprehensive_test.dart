import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/parser/markdown_dynamic_parser.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

void main() {
  group('Comprehensive Tests', () {
    test('Parse complex markdown with all new features', () {
      const markdown = '''
# Complex Popup Example

This is a complex popup with various components.

:::dc<textfield id="full_name" required label="Full Name" placeholder="Enter your full name"/>dc:::

:::dc<textarea id="comments" label="Additional Comments" placeholder="Any additional information..."/>dc:::

:::dc<radiobutton id="age_group" required label="Age Group">
  <option id="18-25">18-25</option>
  <option id="26-35">26-35</option>
  <option id="36-50">36-50</option>
  <option id="50+">50+</option>
</radiobutton>dc:::

:::dc<checkbox id="interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
  <option id="music">Music</option>
  <option id="travel">Travel</option>
</checkbox>dc:::

:::dc<dropdown id="country" required label="Country of Residence">
  <option id="us">United States</option>
  <option id="ca">Canada</option>
  <option id="uk">United Kingdom</option>
  <option id="au">Australia</option>
</dropdown>dc:::

Thank you for your time!
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      
      // Should have 5 components
      expect(result.components.length, 5);
      
      // Check textfield
      final textField = result.components[0];
      expect(textField.type, DynamicComponentType.textField);
      expect(textField.id, 'full_name');
      expect(textField.label, 'Full Name');
      expect(textField.isRequired, true);
      expect(textField.placeholder, 'Enter your full name');
      
      // Check textarea
      final textArea = result.components[1];
      expect(textArea.type, DynamicComponentType.textArea);
      expect(textArea.id, 'comments');
      expect(textArea.label, 'Additional Comments');
      expect(textArea.isRequired, false);
      expect(textArea.placeholder, 'Any additional information...');
      
      // Check radiobutton
      final radioButton = result.components[2];
      expect(radioButton.type, DynamicComponentType.radioButton);
      expect(radioButton.id, 'age_group');
      expect(radioButton.label, 'Age Group');
      expect(radioButton.isRequired, true);
      expect(radioButton.optionData, isNotNull);
      expect(radioButton.optionData!.length, 4);
      expect(radioButton.optionData![0].id, '18-25');
      expect(radioButton.optionData![0].text, '18-25');
      
      // Check checkbox
      final checkbox = result.components[3];
      expect(checkbox.type, DynamicComponentType.checkbox);
      expect(checkbox.id, 'interests');
      expect(checkbox.label, 'Interests');
      expect(checkbox.isRequired, false);
      expect(checkbox.optionData, isNotNull);
      expect(checkbox.optionData!.length, 4);
      expect(checkbox.optionData![1].id, 'sports');
      expect(checkbox.optionData![1].text, 'Sports');
      
      // Check dropdown
      final dropdown = result.components[4];
      expect(dropdown.type, DynamicComponentType.dropdown);
      expect(dropdown.id, 'country');
      expect(dropdown.label, 'Country of Residence');
      expect(dropdown.isRequired, true);
      expect(dropdown.optionData, isNotNull);
      expect(dropdown.optionData!.length, 4);
      expect(dropdown.optionData![2].id, 'uk');
      expect(dropdown.optionData![2].text, 'United Kingdom');
      
      // Check that we still have backward compatibility
      expect(radioButton.options, isNotNull);
      expect(radioButton.options!.length, 4);
      expect(radioButton.options![0], '18-25');
    });
    
    test('Parse single component with new syntax', () {
      const markdown = '''
# Single Component Test

:::dc<textfield id="test" required label="Test Field" placeholder="Enter text"/>dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      
      // Should have 1 component
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.type, DynamicComponentType.textField);
      expect(component.id, 'test');
      expect(component.label, 'Test Field');
      expect(component.isRequired, true);
      expect(component.placeholder, 'Enter text');
    });
  });
}