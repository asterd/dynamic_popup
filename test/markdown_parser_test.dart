import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/parser/markdown_dynamic_parser.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

void main() {
  group('MarkdownDynamicParser Tests', () {
    test('Parse new HTML-like syntax components with improved initiator', () {
      const markdown = '''
# Test
:::dc<textfield id="name" required label="Full Name" placeholder="Enter your name"/>dc:::

Some text here
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      print('Test 1 - Number of components: ${result.components.length}');
      
      // Should have components
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.type, DynamicComponentType.textField);
      expect(component.id, 'name');
      expect(component.label, 'Full Name');
      expect(component.isRequired, true);
      expect(component.placeholder, 'Enter your name');
    });
    
    test('Parse new HTML-like syntax with options and IDs', () {
      const markdown = '''
# Test
:::dc<radiobutton id="choice" required label="Select one">
  <option id="1">Option 1</option>
  <option id="2">Option 2</option>
</radiobutton>dc:::

Some text here
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      print('Test 2 - Number of components: ${result.components.length}');
      print('Content flow length: ${result.contentFlow.length}');
      for (var i = 0; i < result.contentFlow.length; i++) {
        print('Content $i: type=${result.contentFlow[i].type}, markdown=${result.contentFlow[i].markdownContent}, component=${result.contentFlow[i].component}');
      }
      
      // Should have components
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.type, DynamicComponentType.radioButton);
      expect(component.id, 'choice');
      expect(component.label, 'Select one');
      expect(component.isRequired, true);
      
      // Check that we have option data with IDs
      expect(component.optionData, isNotNull);
      expect(component.optionData!.length, 2);
      expect(component.optionData![0].id, '1');
      expect(component.optionData![0].text, 'Option 1');
      expect(component.optionData![1].id, '2');
      expect(component.optionData![1].text, 'Option 2');
      
      // Check backward compatibility
      expect(component.options, isNotNull);
      expect(component.options!.length, 2);
      expect(component.options![0], 'Option 1');
      expect(component.options![1], 'Option 2');
    });
  });
}