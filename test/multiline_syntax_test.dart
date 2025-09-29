import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/parser/markdown_dynamic_parser.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

void main() {
  group('Multiline Syntax Support Tests', () {
    test('Standard inline syntax still works', () {
      const markdown = '''
# Test

:::dc<textfield id="name" required label="Full Name" placeholder="Enter your name"/>dc:::

Text.
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      expect(result.components[0].type, DynamicComponentType.textField);
      expect(result.components[0].id, 'name');
    });
    
    test('Multiline with newlines', () {
      const markdown = '''
# Test

:::dc
<textfield id="name" required label="Full Name" placeholder="Enter your name"/>
dc:::

Text.
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      expect(result.components[0].type, DynamicComponentType.textField);
      expect(result.components[0].id, 'name');
    });
    
    test('Multiline with spaces', () {
      const markdown = '''
# Test

:::dc   
<textfield id="name" required label="Full Name" placeholder="Enter your name"/>
   dc:::

Text.
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      expect(result.components[0].type, DynamicComponentType.textField);
      expect(result.components[0].id, 'name');
    });
    
    test('Multiline with tabs', () {
      const markdown = '''
# Test

:::dc	<textfield id="name" required label="Full Name" placeholder="Enter your name"/>	dc:::

Text.
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      expect(result.components[0].type, DynamicComponentType.textField);
      expect(result.components[0].id, 'name');
    });
    
    test('Multiline container component', () {
      const markdown = '''
# Test

:::dc
<radiobutton id="choice" required label="Select one">
  <option id="1">Option 1</option>
  <option id="2">Option 2</option>
</radiobutton>
dc:::

Text.
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      expect(result.components[0].type, DynamicComponentType.radioButton);
      expect(result.components[0].id, 'choice');
      expect(result.components[0].optionData!.length, 2);
      expect(result.components[0].optionData![0].id, '1');
      expect(result.components[0].optionData![1].id, '2');
    });
    
    test('Multiple multiline components', () {
      const markdown = '''
# Test

:::dc
<textfield id="name" required label="Full Name" placeholder="Enter your name"/>
dc:::

:::dc	
<checkbox id="interests" label="Interests">
  <option id="tech">Technology</option>
  <option id="sports">Sports</option>
</checkbox>
	dc:::

Text.
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 2);
      expect(result.components[0].type, DynamicComponentType.textField);
      expect(result.components[0].id, 'name');
      expect(result.components[1].type, DynamicComponentType.checkbox);
      expect(result.components[1].id, 'interests');
      expect(result.components[1].optionData!.length, 2);
    });
  });
}