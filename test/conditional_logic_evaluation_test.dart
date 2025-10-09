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
      expect(logic.isMet('yes'), true);
      expect(logic.isMet('YES'), true);
      expect(logic.isMet('Yes'), true);
      expect(logic.isMet('no'), false);
    });
    
    test('Conditional logic notEquals condition - case insensitive', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'notEquals',
        value: 'YES',
      );
      
      // Test case insensitive matching
      expect(logic.isMet('yes'), false);
      expect(logic.isMet('YES'), false);
      expect(logic.isMet('no'), true);
      expect(logic.isMet('NO'), true);
    });
    
    test('Conditional logic contains condition - list values', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'contains',
        value: 'option1',
      );
      
      // Test with list values (checkbox)
      expect(logic.isMet(['option1', 'option2']), true);
      expect(logic.isMet(['option2', 'option3']), false);
      expect(logic.isMet([]), false);
    });
    
    test('Conditional logic notContains condition - list values', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'notContains',
        value: 'option1',
      );
      
      // Test with list values (checkbox)
      expect(logic.isMet(['option2', 'option3']), true);
      expect(logic.isMet(['option1', 'option2']), false);
      expect(logic.isMet([]), true);
    });
  });
}