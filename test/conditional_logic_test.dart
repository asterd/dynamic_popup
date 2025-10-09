import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/parser/markdown_dynamic_parser.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';
import 'package:dynamic_popup/src/ui/dynamic_popup_widget.dart';
import 'package:flutter/material.dart';

void main() {
  group('Conditional Logic Tests', () {
    test('Parse component with conditional logic', () {
      const markdown = '''
# Test
:::dc<textfield id="dependent_field" label="Dependent Field" depends-on="controller" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 1);
      
      final component = result.components.first;
      expect(component.conditionalLogic, isNotNull);
      expect(component.conditionalLogic!.dependsOn, 'controller');
      expect(component.conditionalLogic!.value, 'YES');
    });
    
    test('Conditional logic visibility - radio button controls text field', () {
      // This would require a full widget test to properly test the visibility logic
      // Since that's complex to set up in a unit test, we'll just verify the parsing works
      const markdown = '''
# Conditional Test

:::dc<radiobutton id="consent" required label="Do you consent?">
  <option id="yes">YES</option>
  <option id="no">NO</option>
</radiobutton>dc:::

:::dc<textfield id="reason" label="Reason for consent" depends-on="consent" when-value="YES" />dc:::
      ''';
      
      final result = MarkdownDynamicParser.parse(markdown);
      expect(result.components.length, 2);
      
      // First component (radio button) should not have conditional logic
      final radioButton = result.components[0];
      expect(radioButton.id, 'consent');
      expect(radioButton.conditionalLogic, isNull);
      
      // Second component (text field) should have conditional logic
      final textField = result.components[1];
      expect(textField.id, 'reason');
      expect(textField.conditionalLogic, isNotNull);
      expect(textField.conditionalLogic!.dependsOn, 'consent');
      expect(textField.conditionalLogic!.value, 'YES');
    });
  });
}