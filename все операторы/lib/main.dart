import 'dart:io';
import 'operators_demo.dart';

void main() {
  print('=' * 60);
  print('ДЕМОНСТРАЦИЯ ВСЕХ ОПЕРАТОРОВ FLUTTER/DART');
  print('=' * 60);
  
  final demo = OperatorsDemo();
  
  while (true) {
    print('\nВыберите категорию операторов:');
    print('1. Арифметические операторы');
    print('2. Операторы сравнения');
    print('3. Логические операторы');
    print('4. Операторы присваивания');
    print('5. Побитовые операторы');
    print('6. Условные операторы');
    print('7. Операторы типов');
    print('8. Каскадные операторы');
    print('9. Null-aware операторы');
    print('10. Специально: ?. , ? , ?[]');
    print('11. Показать все операторы');
    print('0. Выход');
    print('\nВведите номер (0-11): ');
    
    final input = stdin.readLineSync()?.trim();
    
    switch (input) {
      case '1':
        demo.showArithmeticOperators();
        break;
      case '2':
        demo.showComparisonOperators();
        break;
      case '3':
        demo.showLogicalOperators();
        break;
      case '4':
        demo.showAssignmentOperators();
        break;
      case '5':
        demo.showBitwiseOperators();
        break;
      case '6':
        demo.showConditionalOperators();
        break;
      case '7':
        demo.showTypeOperators();
        break;
      case '8':
        demo.showCascadeOperators();
        break;
      case '9':
        demo.showNullAwareOperators();
        break;
      case '10':
        demo.showSpecificNullAwareOperators();
        break;
      case '11':
        demo.showAllOperators();
        break;
      case '0':
        print('\nДо свидания!');
        exit(0);
      default:
        print('\nНеверный выбор. Попробуйте снова.');
    }
    
    print('\n' + '-' * 60);
    print('Нажмите Enter для продолжения...');
    stdin.readLineSync();
  }
}
