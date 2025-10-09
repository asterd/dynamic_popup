import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/parser/markdown_dynamic_parser.dart';

void main() {
  group('Required When Value Tests', () {
    test('Parse component with required-when-value attribute', () {
      const markdown = '''
:::dc<textfield id="conditional_required_field" label="Conditional Required Field" required-when-value="true" depends-on="controller" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.conditionalLogic, isNotNull);
      expect(component.conditionalLogic!.dependsOn, 'controller');
      expect(component.conditionalLogic!.value, 'YES');
      expect(component.conditionalLogic!.requiredWhenValue, 'true');
    });
    
    test('Parse component with required-when-value set to false', () {
      const markdown = '''
:::dc<textfield id="conditional_not_required_field" label="Conditional Not Required Field" required-when-value="false" depends-on="controller" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.conditionalLogic, isNotNull);
      expect(component.conditionalLogic!.dependsOn, 'controller');
      expect(component.conditionalLogic!.value, 'YES');
      expect(component.conditionalLogic!.requiredWhenValue, 'false');
    });
  });
}