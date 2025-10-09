import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

void main() {
  group('Conditional Logic Evaluation Tests', () {
    test('Conditional logic equals condition - case insensitive', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'equals',
        value: 'YES',
      );
      
      // Test case insensitive matching
      expect(logic.isVisibilityMet('yes'), true);
      expect(logic.isVisibilityMet('YES'), true);
      expect(logic.isVisibilityMet('Yes'), true);
      expect(logic.isVisibilityMet('no'), false);
    });
    
    test('Conditional logic notEquals condition - case insensitive', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'notEquals',
        value: 'YES',
      );
      
      // Test case insensitive matching
      expect(logic.isVisibilityMet('yes'), false);
      expect(logic.isVisibilityMet('YES'), false);
      expect(logic.isVisibilityMet('no'), true);
      expect(logic.isVisibilityMet('NO'), true);
    });
    
    test('Conditional logic contains condition - list values', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'contains',
        value: 'option1',
      );
      
      // Test with list values (checkbox)
      expect(logic.isVisibilityMet(['option1', 'option2']), true);
      expect(logic.isVisibilityMet(['option2', 'option3']), false);
      expect(logic.isVisibilityMet([]), false);
    });
    
    test('Conditional logic notContains condition - list values', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'notContains',
        value: 'option1',
      );
      
      // Test with list values (checkbox)
      expect(logic.isVisibilityMet(['option2', 'option3']), true);
      expect(logic.isVisibilityMet(['option1', 'option2']), false);
      expect(logic.isVisibilityMet([]), true);
    });
  });
}