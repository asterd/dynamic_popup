import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_popup/src/data/model/dynamic_component.dart';

void main() {
  group('Conditional Required Tests', () {
    test('ConditionalLogic with requiredWhenVisible true', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'equals',
        value: 'YES',
        requiredWhenVisible: true,
      );
      
      expect(logic.requiredWhenVisible, true);
    });
    
    test('ConditionalLogic with requiredWhenVisible false', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'equals',
        value: 'YES',
        requiredWhenVisible: false,
      );
      
      expect(logic.requiredWhenVisible, false);
    });
    
    test('ConditionalLogic with requiredWhenVisible null', () {
      final logic = ConditionalLogic(
        dependsOn: 'test_field',
        condition: 'equals',
        value: 'YES',
      );
      
      expect(logic.requiredWhenVisible, null);
    });
  });
}