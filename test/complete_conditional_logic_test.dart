import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/parser/markdown_dynamic_parser.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

void main() {
  group('Complete Conditional Logic Tests', () {
    test('Parse component with conditional visibility', () {
      const markdown = '''
:::dc<textfield id="dependent_field" label="Dependent Field" depends-on="controller" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.conditionalLogic, isNotNull);
      expect(component.conditionalLogic!.dependsOn, 'controller');
      expect(component.conditionalLogic!.value, 'YES');
      expect(component.conditionalLogic!.requiredWhenVisible, null);
    });
    
    test('Parse component with conditional required status', () {
      const markdown = '''
:::dc<textfield id="conditional_required_field" label="Conditional Required Field" required-when-visible="true" depends-on="controller" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.conditionalLogic, isNotNull);
      expect(component.conditionalLogic!.dependsOn, 'controller');
      expect(component.conditionalLogic!.value, 'YES');
      expect(component.conditionalLogic!.requiredWhenVisible, true);
    });
    
    test('Parse component with conditional required status set to false', () {
      const markdown = '''
:::dc<textfield id="conditional_not_required_field" label="Conditional Not Required Field" required-when-visible="false" depends-on="controller" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.conditionalLogic, isNotNull);
      expect(component.conditionalLogic!.dependsOn, 'controller');
      expect(component.conditionalLogic!.value, 'YES');
      expect(component.conditionalLogic!.requiredWhenVisible, false);
    });
  });
}