
import 'dart:io';

class OperatorsDemo {
  
  // Арифметические операторы
  void showArithmeticOperators() {
    print('\n' + '=' * 50);
    print('АРИФМЕТИЧЕСКИЕ ОПЕРАТОРЫ');
    print('=' * 50);
    
    int a = 10;
    int b = 3;
    double c = 10.0;
    double d = 3.0;
    
    print('a = $a, b = $b, c = $c, d = $d\n');
    
    // Сложение
    print('Сложение (+)');
    print('a + b = $a + $b = ${a + b}');
    print('c + d = $c + $d = ${c + d}');
    
    // Вычитание
    print('\nВычитание (-)');
    print('a - b = $a - $b = ${a - b}');
    print('c - d = $c - $d = ${c - d}');
    
    // Умножение
    print('\nУмножение (*)');
    print('a * b = $a * $b = ${a * b}');
    print('c * d = $c * $d = ${c * d}');
    
    // Деление
    print('\nДеление (/)');
    print('a / b = $a / $b = ${a / b}');
    print('c / d = $c / $d = ${c / d}');
    
    // Целочисленное деление
    print('\nЦелочисленное деление (~/)');
    print('a ~/ b = $a ~/ $b = ${a ~/ b}');
    print('c ~/ d = $c ~/ $d = ${c ~/ d}');
    
    // Остаток от деления
    print('\nОстаток от деления (%)');
    print('a % b = $a % $b = ${a % b}');
    print('c % d = $c % $d = ${c % d}');
    
    // Унарные операторы
    print('\nУнарные операторы');
    print('a = $a (положительное число)');
    print('-a = -$a = ${-a}');
    print('++a = ++$a = ${++a} (a теперь = $a)');
    print('--a = --$a = ${--a} (a теперь = $a)');
    print('a++ = $a++ = ${a++} (a теперь = $a)');
    print('a-- = $a-- = ${a--} (a теперь = $a)');
  }
  
  // Операторы сравнения
  void showComparisonOperators() {
    print('\n' + '=' * 50);
    print('ОПЕРАТОРЫ СРАВНЕНИЯ');
    print('=' * 50);
    
    int a = 10;
    int b = 5;
    int c = 10;
    String str1 = 'Hello';
    String str2 = 'World';
    String str3 = 'Hello';
    
    print('a = $a, b = $b, c = $c');
    print('str1 = "$str1", str2 = "$str2", str3 = "$str3"\n');
    
    // Равенство
    print('Равенство (==)');
    print('a == b = $a == $b = ${a == b}');
    print('a == c = $a == $c = ${a == c}');
    print('str1 == str2 = "$str1" == "$str2" = ${str1 == str2}');
    print('str1 == str3 = "$str1" == "$str3" = ${str1 == str3}');
    
    // Неравенство
    print('\nНеравенство (!=)');
    print('a != b = $a != $b = ${a != b}');
    print('a != c = $a != $c = ${a != c}');
    
    // Больше
    print('\nБольше (>)');
    print('a > b = $a > $b = ${a > b}');
    print('b > a = $b > $a = ${b > a}');
    
    // Меньше
    print('\nМеньше (<)');
    print('a < b = $a < $b = ${a < b}');
    print('b < a = $b < $a = ${b < a}');
    
    // Больше или равно
    print('\nБольше или равно (>=)');
    print('a >= b = $a >= $b = ${a >= b}');
    print('a >= c = $a >= $c = ${a >= c}');
    print('b >= a = $b >= $a = ${b >= a}');
    
    // Меньше или равно
    print('\nМеньше или равно (<=)');
    print('a <= b = $a <= $b = ${a <= b}');
    print('a <= c = $a <= $c = ${a <= c}');
    print('b <= a = $b <= $a = ${b <= a}');
  }
  
  // Логические операторы
  void showLogicalOperators() {
    print('\n' + '=' * 50);
    print('ЛОГИЧЕСКИЕ ОПЕРАТОРЫ');
    print('=' * 50);
    
    bool a = true;
    bool b = false;
    
    print('a = $a, b = $b\n');
    
    // Логическое И
    print('Логическое И (&&)');
    print('a && b = $a && $b = ${a && b}');
    print('a && a = $a && $a = ${a && a}');
    print('b && b = $b && $b = ${b && b}');
    
    // Логическое ИЛИ
    print('\nЛогическое ИЛИ (||)');
    print('a || b = $a || $b = ${a || b}');
    print('a || a = $a || $a = ${a || a}');
    print('b || b = $b || $b = ${b || b}');
    
    // Логическое НЕ
    print('\nЛогическое НЕ (!)');
    print('!a = !$a = ${!a}');
    print('!b = !$b = ${!b}');
    
    // Комбинированные операции
    print('\nКомбинированные операции');
    print('!(a && b) = !($a && $b) = ${!(a && b)}');
    print('!a || !b = !$a || !$b = ${!a || !b}');
    print('(a || b) && !(a && b) = ($a || $b) && !($a && $b) = ${(a || b) && !(a && b)}');
  }
  
  // Операторы присваивания
  void showAssignmentOperators() {
    print('\n' + '=' * 50);
    print('ОПЕРАТОРЫ ПРИСВАИВАНИЯ');
    print('=' * 50);
    
    int a = 10;
    int b = 3;
    
    print('Исходные значения: a = $a, b = $b\n');
    
    // Простое присваивание
    print('Простое присваивание (=)');
    int c = a;
    print('c = a; c = $c');
    
    // Присваивание с сложением
    print('\nПрисваивание с сложением (+=)');
    a += b;
    print('a += b; a = $a');
    
    // Присваивание с вычитанием
    print('\nПрисваивание с вычитанием (-=)');
    a -= b;
    print('a -= b; a = $a');
    
    // Присваивание с умножением
    print('\nПрисваивание с умножением (*=)');
    a *= b;
    print('a *= b; a = $a');
    
    // Присваивание с делением
    print('\nПрисваивание с делением (/=)');
    double d = a.toDouble();
    d /= b;
    print('d /= b; d = $d');
    
    // Присваивание с целочисленным делением
    print('\nПрисваивание с целочисленным делением (~/=)');
    a ~/= b;
    print('a ~/= b; a = $a');
    
    // Присваивание с остатком
    print('\nПрисваивание с остатком (%=)');
    a %= b;
    print('a %= b; a = $a');
    
    // Присваивание с побитовыми операциями
    print('\nПрисваивание с побитовыми операциями');
    a = 12; // 1100 в двоичном
    b = 5;  // 0101 в двоичном
    print('a = $a (1100), b = $b (0101)');
    
    a &= b; // Побитовое И
    print('a &= b; a = $a (${a.toRadixString(2)})');
    
    a = 12;
    a |= b; // Побитовое ИЛИ
    print('a |= b; a = $a (${a.toRadixString(2)})');
    
    a = 12;
    a ^= b; // Побитовое исключающее ИЛИ
    print('a ^= b; a = $a (${a.toRadixString(2)})');
    
    a = 12;
    a <<= 2; // Сдвиг влево
    print('a <<= 2; a = $a (${a.toRadixString(2)})');
    
    a = 12;
    a >>= 2; // Сдвиг вправо
    print('a >>= 2; a = $a (${a.toRadixString(2)})');
  }
  
  // Побитовые операторы
  void showBitwiseOperators() {
    print('\n' + '=' * 50);
    print('ПОБИТОВЫЕ ОПЕРАТОРЫ');
    print('=' * 50);
    
    int a = 12; // 1100 в двоичном
    int b = 5;  // 0101 в двоичном
    
    print('a = $a (${a.toRadixString(2).padLeft(4, '0')})');
    print('b = $b (${b.toRadixString(2).padLeft(4, '0')})\n');
    
    // Побитовое И
    print('Побитовое И (&)');
    int result = a & b;
    print('a & b = $a & $b = $result (${result.toRadixString(2).padLeft(4, '0')})');
    
    // Побитовое ИЛИ
    print('\nПобитовое ИЛИ (|)');
    result = a | b;
    print('a | b = $a | $b = $result (${result.toRadixString(2).padLeft(4, '0')})');
    
    // Побитовое исключающее ИЛИ
    print('\nПобитовое исключающее ИЛИ (^)');
    result = a ^ b;
    print('a ^ b = $a ^ $b = $result (${result.toRadixString(2).padLeft(4, '0')})');
    
    // Побитовое НЕ
    print('\nПобитовое НЕ (~)');
    result = ~a;
    print('~a = ~$a = $result (${result.toRadixString(2)})');
    
    // Сдвиг влево
    print('\nСдвиг влево (<<)');
    result = a << 2;
    print('a << 2 = $a << 2 = $result (${result.toRadixString(2).padLeft(6, '0')})');
    
    // Сдвиг вправо
    print('\nСдвиг вправо (>>)');
    result = a >> 2;
    print('a >> 2 = $a >> 2 = $result (${result.toRadixString(2).padLeft(4, '0')})');
  }
  
  // Условные операторы
  void showConditionalOperators() {
    print('\n' + '=' * 50);
    print('УСЛОВНЫЕ ОПЕРАТОРЫ');
    print('=' * 50);
    
    int a = 10;
    int b = 5;
    String? nullableString;
    String? anotherNullableString = 'Hello';
    
    print('a = $a, b = $b');
    print('nullableString = $nullableString');
    print('anotherNullableString = $anotherNullableString\n');
    
    // Тернарный оператор
    print('Тернарный оператор (?:)');
    String result = a > b ? 'a больше b' : 'a не больше b';
    print('a > b ? "a больше b" : "a не больше b" = "$result"');
    
    int max = a > b ? a : b;
    print('a > b ? a : b = $a > $b ? $a : $b = $max');
    
    // Оператор null-coalescing
    print('\nОператор null-coalescing (??)');
    String result1 = nullableString ?? 'Значение по умолчанию';
    print('nullableString ?? "Значение по умолчанию" = "$result1"');
    
    String result2 = anotherNullableString ?? 'Значение по умолчанию';
    print('anotherNullableString ?? "Значение по умолчанию" = "$result2"');
    
    // Оператор null-coalescing assignment
    print('\nОператор null-coalescing assignment (??=)');
    String? testString;
    print('testString = $testString');
    testString ??= 'Новое значение';
    print('testString ??= "Новое значение"; testString = $testString');
    
    testString ??= 'Другое значение';
    print('testString ??= "Другое значение"; testString = $testString');
    
    // Комбинированные условные операторы
    print('\nКомбинированные условные операторы');
    int? nullableInt;
    int finalValue = nullableInt ?? (a > b ? a : b);
    print('nullableInt ?? (a > b ? a : b) = $nullableInt ?? ($a > $b ? $a : $b) = $finalValue');
  }
  
  // Операторы типов
  void showTypeOperators() {
    print('\n' + '=' * 50);
    print('ОПЕРАТОРЫ ТИПОВ');
    print('=' * 50);
    
    Object obj1 = 'Hello';
    Object obj2 = 42;
    Object obj3 = 3.14;
    Object obj4 = [1, 2, 3];
    
    print('obj1 = "$obj1" (тип: ${obj1.runtimeType})');
    print('obj2 = $obj2 (тип: ${obj2.runtimeType})');
    print('obj3 = $obj3 (тип: ${obj3.runtimeType})');
    print('obj4 = $obj4 (тип: ${obj4.runtimeType})\n');
    
    // Оператор is
    print('Оператор is (проверка типа)');
    print('obj1 is String = ${obj1 is String}');
    print('obj1 is int = ${obj1 is int}');
    print('obj2 is int = ${obj2 is int}');
    print('obj2 is String = ${obj2 is String}');
    print('obj3 is double = ${obj3 is double}');
    print('obj4 is List = ${obj4 is List}');
    
    // Оператор is!
    print('\nОператор is! (отрицание проверки типа)');
    print('obj1 is! String = ${obj1 is! String}');
    print('obj1 is! int = ${obj1 is! int}');
    print('obj2 is! int = ${obj2 is! int}');
    print('obj2 is! String = ${obj2 is! String}');
    
    // Оператор as
    print('\nОператор as (приведение типа)');
    if (obj1 is String) {
      String str = obj1 as String;
      print('obj1 as String = "$str" (длина: ${str.length})');
    }
    
    if (obj2 is int) {
      int num = obj2 as int;
      print('obj2 as int = $num (квадрат: ${num * num})');
    }
    
    if (obj4 is List) {
      List list = obj4 as List;
      print('obj4 as List = $list (размер: ${list.length})');
    }
    
    // Безопасное приведение типов
    print('\nБезопасное приведение типов');
    String? safeString = obj1 is String ? obj1 as String : null;
    print('obj1 is String ? obj1 as String : null = $safeString');
    
    int? safeInt = obj1 is int ? obj1 as int : null;
    print('obj1 is int ? obj1 as int : null = $safeInt');
  }
  
  // Каскадные операторы
  void showCascadeOperators() {
    print('\n' + '=' * 50);
    print('КАСКАДНЫЕ ОПЕРАТОРЫ');
    print('=' * 50);
    
    // Демонстрация с List
    print('Каскадные операторы с List (..)');
    List<int> numbers = <int>[]
      ..add(1)
      ..add(2)
      ..add(3)
      ..addAll([4, 5, 6])
      ..sort();
    
    print('List<int> numbers = <int>[]');
    print('  ..add(1)');
    print('  ..add(2)');
    print('  ..add(3)');
    print('  ..addAll([4, 5, 6])');
    print('  ..sort();');
    print('Результат: $numbers');
    
    // Демонстрация с StringBuffer
    print('\nКаскадные операторы с StringBuffer');
    StringBuffer buffer = StringBuffer()
      ..write('Hello')
      ..write(' ')
      ..write('World')
      ..write('!');
    
    print('StringBuffer buffer = StringBuffer()');
    print('  ..write("Hello")');
    print('  ..write(" ")');
    print('  ..write("World")');
    print('  ..write("!");');
    print('Результат: "${buffer.toString()}"');
    
    // Демонстрация с Map
    print('\nКаскадные операторы с Map');
    Map<String, dynamic> person = <String, dynamic>{}
      ..['name'] = 'Иван'
      ..['age'] = 25
      ..['city'] = 'Москва'
      ..['isStudent'] = true;
    
    print('Map<String, dynamic> person = <String, dynamic>{}');
    print('  ..["name"] = "Иван"');
    print('  ..["age"] = 25');
    print('  ..["city"] = "Москва"');
    print('  ..["isStudent"] = true;');
    print('Результат: $person');
    
    // Демонстрация с Set
    print('\nКаскадные операторы с Set');
    Set<String> fruits = <String>{}
      ..add('яблоко')
      ..add('банан')
      ..add('апельсин')
      ..add('яблоко'); // дубликат не добавится
    
    print('Set<String> fruits = <String>{}');
    print('  ..add("яблоко")');
    print('  ..add("банан")');
    print('  ..add("апельсин")');
    print('  ..add("яблоко"); // дубликат');
    print('Результат: $fruits');
  }
  
  // Показать все операторы
  void showAllOperators() {
    print('\n' + '=' * 60);
    print('ВСЕ ОПЕРАТОРЫ FLUTTER/DART');
    print('=' * 60);
    
    showArithmeticOperators();
    showComparisonOperators();
    showLogicalOperators();
    showAssignmentOperators();
    showBitwiseOperators();
    showConditionalOperators();
    showTypeOperators();
    showCascadeOperators();
    showNullAwareOperators();
    
    print('\n' + '=' * 60);
    print('ДОПОЛНИТЕЛЬНЫЕ ОПЕРАТОРЫ');
    print('=' * 60);
    
    // Операторы доступа
    print('\nОператоры доступа');
    List<int> list = [1, 2, 3, 4, 5];
    Map<String, int> map = {'a': 1, 'b': 2, 'c': 3};
    
    print('list = $list');
    print('map = $map');
    print('list[0] = ${list[0]}');
    print('list[2] = ${list[2]}');
    print('map["a"] = ${map["a"]}');
    print('map["b"] = ${map["b"]}');
    
    // Операторы вызова функций
    print('\nОператоры вызова функций');
    int Function(int, int) add = (a, b) => a + b;
    print('add(5, 3) = ${add(5, 3)}');
    
    // Операторы индексации
    print('\nОператоры индексации');
    list[0] = 10;
    map['d'] = 4;
    print('После изменения:');
    print('list[0] = 10; list = $list');
    print('map["d"] = 4; map = $map');
    
    // Null-aware операторы
    print('\n' + '=' * 50);
    print('NULL-AWARE ОПЕРАТОРЫ');
    print('=' * 50);
    
    List<int>? nullableList;
    List<int>? nonNullList = [1, 2, 3];
    Map<String, int>? nullableMap;
    Map<String, int>? nonNullMap = {'a': 1, 'b': 2};
    
    print('nullableList = $nullableList');
    print('nonNullList = $nonNullList');
    print('nullableMap = $nullableMap');
    print('nonNullMap = $nonNullMap\n');
    
    // Оператор ?. (null-aware member access)
    print('Оператор ?. (null-aware member access)');
    print('nullableList?.length = ${nullableList?.length}');
    print('nonNullList?.length = ${nonNullList?.length}');
    print('nullableMap?.length = ${nullableMap?.length}');
    print('nonNullMap?.length = ${nonNullMap?.length}');
    
    // Оператор ?[] (null-aware index access)
    print('\nОператор ?[] (null-aware index access)');
    print('nullableList?[0] = ${nullableList?[0]}');
    print('nonNullList?[0] = ${nonNullList?[0]}');
    print('nullableMap?["a"] = ${nullableMap?["a"]}');
    print('nonNullMap?["a"] = ${nonNullMap?["a"]}');
    
    // Оператор ?? (null-coalescing)
    print('\nОператор ?? (null-coalescing)');
    int? nullableInt;
    int? anotherNullableInt = 42;
    print('nullableInt ?? 0 = ${nullableInt ?? 0}');
    print('anotherNullableInt ?? 0 = ${anotherNullableInt ?? 0}');
    print('nullableList ?? [99, 100] = ${nullableList ?? [99, 100]}');
    print('nonNullList ?? [99, 100] = ${nonNullList ?? [99, 100]}');
    
    // Оператор ??= (null-coalescing assignment)
    print('\nОператор ??= (null-coalescing assignment)');
    int? testInt;
    print('testInt = $testInt');
    testInt ??= 100;
    print('testInt ??= 100; testInt = $testInt');
    testInt ??= 200;
    print('testInt ??= 200; testInt = $testInt');
    
    List<int>? testList;
    print('testList = $testList');
    testList ??= [1, 2, 3];
    print('testList ??= [1, 2, 3]; testList = $testList');
    testList ??= [4, 5, 6];
    print('testList ??= [4, 5, 6]; testList = $testList');
    
    // Комбинированные null-aware операции
    print('\nКомбинированные null-aware операции');
    List<int>? complexList;
    print('complexList = $complexList');
    print('complexList?.length ?? 0 = ${complexList?.length ?? 0}');
    print('complexList?[0] ?? -1 = ${complexList?[0] ?? -1}');
    
    complexList = [10, 20, 30];
    print('complexList = $complexList');
    print('complexList?.length ?? 0 = ${complexList?.length ?? 0}');
    print('complexList?[0] ?? -1 = ${complexList?[0] ?? -1}');
    
    // Null-aware с методами
    print('\nNull-aware с методами');
    String? nullableString;
    print('nullableString = $nullableString');
    print('nullableString?.toUpperCase() = ${nullableString?.toUpperCase()}');
    print('nullableString?.toUpperCase() ?? "DEFAULT" = ${nullableString?.toUpperCase() ?? "DEFAULT"}');
    
    nullableString = "hello";
    print('nullableString = $nullableString');
    print('nullableString?.toUpperCase() = ${nullableString?.toUpperCase()}');
    print('nullableString?.toUpperCase() ?? "DEFAULT" = ${nullableString?.toUpperCase() ?? "DEFAULT"}');
  }
  
  // Null-aware операторы (отдельная функция)
  void showNullAwareOperators() {
    print('\n' + '=' * 50);
    print('NULL-AWARE ОПЕРАТОРЫ');
    print('=' * 50);
    
    List<int>? nullableList;
    List<int>? nonNullList = [1, 2, 3];
    Map<String, int>? nullableMap;
    Map<String, int>? nonNullMap = {'a': 1, 'b': 2};
    
    print('nullableList = $nullableList');
    print('nonNullList = $nonNullList');
    print('nullableMap = $nullableMap');
    print('nonNullMap = $nonNullMap\n');
    
    // Оператор ?. (null-aware member access)
    print('Оператор ?. (null-aware member access)');
    print('nullableList?.length = ${nullableList?.length}');
    print('nonNullList?.length = ${nonNullList?.length}');
    print('nullableMap?.length = ${nullableMap?.length}');
    print('nonNullMap?.length = ${nonNullMap?.length}');
    
    // Оператор ?[] (null-aware index access)
    print('\nОператор ?[] (null-aware index access)');
    print('nullableList?[0] = ${nullableList?[0]}');
    print('nonNullList?[0] = ${nonNullList?[0]}');
    print('nullableMap?["a"] = ${nullableMap?["a"]}');
    print('nonNullMap?["a"] = ${nonNullMap?["a"]}');
    
    // Оператор ?? (null-coalescing)
    print('\nОператор ?? (null-coalescing)');
    int? nullableInt;
    int? anotherNullableInt = 42;
    print('nullableInt ?? 0 = ${nullableInt ?? 0}');
    print('anotherNullableInt ?? 0 = ${anotherNullableInt ?? 0}');
    print('nullableList ?? [99, 100] = ${nullableList ?? [99, 100]}');
    print('nonNullList ?? [99, 100] = ${nonNullList ?? [99, 100]}');
    
    // Оператор ??= (null-coalescing assignment)
    print('\nОператор ??= (null-coalescing assignment)');
    int? testInt;
    print('testInt = $testInt');
    testInt ??= 100;
    print('testInt ??= 100; testInt = $testInt');
    testInt ??= 200;
    print('testInt ??= 200; testInt = $testInt');
    
    List<int>? testList;
    print('testList = $testList');
    testList ??= [1, 2, 3];
    print('testList ??= [1, 2, 3]; testList = $testList');
    testList ??= [4, 5, 6];
    print('testList ??= [4, 5, 6]; testList = $testList');
    
    // Комбинированные null-aware операции
    print('\nКомбинированные null-aware операции');
    List<int>? complexList;
    print('complexList = $complexList');
    print('complexList?.length ?? 0 = ${complexList?.length ?? 0}');
    print('complexList?[0] ?? -1 = ${complexList?[0] ?? -1}');
    
    complexList = [10, 20, 30];
    print('complexList = $complexList');
    print('complexList?.length ?? 0 = ${complexList?.length ?? 0}');
    print('complexList?[0] ?? -1 = ${complexList?[0] ?? -1}');
    
    // Null-aware с методами
    print('\nNull-aware с методами');
    String? nullableString;
    print('nullableString = $nullableString');
    print('nullableString?.toUpperCase() = ${nullableString?.toUpperCase()}');
    print('nullableString?.toUpperCase() ?? "DEFAULT" = ${nullableString?.toUpperCase() ?? "DEFAULT"}');
    
    nullableString = "hello";
    print('nullableString = $nullableString');
    print('nullableString?.toUpperCase() = ${nullableString?.toUpperCase()}');
    print('nullableString?.toUpperCase() ?? "DEFAULT" = ${nullableString?.toUpperCase() ?? "DEFAULT"}');
    
    // Практические примеры
    print('\nПрактические примеры');
    Map<String, dynamic>? user;
    print('user = $user');
    print('user?["name"] ?? "Гость" = ${user?["name"] ?? "Гость"}');
    print('user?["age"] ?? 0 = ${user?["age"] ?? 0}');
    
    user = {"name": "Иван", "age": 25};
    print('user = $user');
    print('user?["name"] ?? "Гость" = ${user?["name"] ?? "Гость"}');
    print('user?["age"] ?? 0 = ${user?["age"] ?? 0}');
    
    // Дополнительные примеры оператора ?. (null-aware member access)
    print('\nДополнительные примеры оператора ?. (null-aware member access)');
    String? text;
    print('text = $text');
    print('text?.length = ${text?.length}');
    print('text?.toUpperCase() = ${text?.toUpperCase()}');
    print('text?.isEmpty = ${text?.isEmpty}');
    
    text = "Hello World";
    print('text = "$text"');
    print('text?.length = ${text?.length}');
    print('text?.toUpperCase() = ${text?.toUpperCase()}');
    print('text?.isEmpty = ${text?.isEmpty}');
    
    // Примеры с объектами
    print('\nПримеры с объектами');
    List<String>? names;
    print('names = $names');
    print('names?.first = ${names?.first}');
    print('names?.last = ${names?.last}');
    print('names?.isEmpty = ${names?.isEmpty}');
    
    names = ["Анна", "Борис", "Виктор"];
    print('names = $names');
    print('names?.first = ${names?.first}');
    print('names?.last = ${names?.last}');
    print('names?.isEmpty = ${names?.isEmpty}');
    
    // Дополнительные примеры оператора ?[] (null-aware index access)
    print('\nДополнительные примеры оператора ?[] (null-aware index access)');
    List<int>? numbers;
    print('numbers = $numbers');
    print('numbers?[0] = ${numbers?[0]}');
    print('numbers?[1] = ${numbers?[1]}');
    print('numbers?[10] = ${numbers?[10]}'); // Индекс вне диапазона
    
    numbers = [10, 20, 30, 40, 50];
    print('numbers = $numbers');
    print('numbers?[0] = ${numbers?[0]}');
    print('numbers?[2] = ${numbers?[2]}');
    print('numbers?[10] = ${numbers?.length != null && 10 < numbers!.length ? numbers[10] : null}'); // Безопасная проверка
    
    // Примеры с Map
    Map<String, String>? config;
    print('config = $config');
    print('config?["theme"] = ${config?["theme"]}');
    print('config?["language"] = ${config?["language"]}');
    
    config = {"theme": "dark", "language": "ru"};
    print('config = $config');
    print('config?["theme"] = ${config?["theme"]}');
    print('config?["language"] = ${config?["language"]}');
    print('config?["font"] = ${config?["font"]}'); // Несуществующий ключ
    
    // Комбинированные примеры
    print('\nКомбинированные примеры');
    Map<String, List<String>>? data;
    print('data = $data');
    print('data?["users"]?[0] = ${data?["users"]?[0]}');
    print('data?["users"]?.length = ${data?["users"]?.length}');
    
    data = {"users": ["Алиса", "Боб", "Чарли"]};
    print('data = $data');
    print('data?["users"]?[0] = ${data?["users"]?[0]}');
    print('data?["users"]?.length = ${data?["users"]?.length}');
    print('data?["users"]?[1]?.toUpperCase() = ${data?["users"]?[1]?.toUpperCase()}');
    
    // Примеры с методами
    print('\nПримеры с методами');
    String? message;
    print('message = $message');
    print('message?.contains("test") = ${message?.contains("test")}');
    print('message?.startsWith("Hello") = ${message?.startsWith("Hello")}');
    
    message = "Hello World";
    print('message = "$message"');
    print('message?.contains("World") = ${message?.contains("World")}');
    print('message?.startsWith("Hello") = ${message?.startsWith("Hello")}');
    print('message?.split(" ")?.length = ${message?.split(" ")?.length}');
  }
  
  // Специальная демонстрация операторов ?. , ? , ?[]
  void showSpecificNullAwareOperators() {
    print('\n' + '=' * 60);
    print('СПЕЦИАЛЬНАЯ ДЕМОНСТРАЦИЯ ОПЕРАТОРОВ: ?. , ? , ?[]');
    print('=' * 60);
    
    print('\n1. ОПЕРАТОР ?. (null-aware member access)');
    print('Позволяет безопасно обращаться к свойствам и методам объекта');
    print('Если объект null, возвращает null вместо ошибки\n');
    
    // Примеры с String
    String? name;
    print('String? name = $name;');
    print('name?.length = ${name?.length}');
    print('name?.toUpperCase() = ${name?.toUpperCase()}');
    print('name?.isEmpty = ${name?.isEmpty}');
    
    name = "Дмитрий";
    print('\nname = "$name";');
    print('name?.length = ${name?.length}');
    print('name?.toUpperCase() = ${name?.toUpperCase()}');
    print('name?.isEmpty = ${name?.isEmpty}');
    
    // Примеры с List
    print('\n2. ОПЕРАТОР ?[] (null-aware index access)');
    print('Позволяет безопасно обращаться к элементам по индексу');
    print('Если объект null, возвращает null вместо ошибки\n');
    
    List<String>? fruits;
    print('List<String>? fruits = $fruits;');
    print('fruits?[0] = ${fruits?[0]}');
    print('fruits?[1] = ${fruits?[1]}');
    
    fruits = ["яблоко", "банан", "апельсин"];
    print('\nfruits = $fruits;');
    print('fruits?[0] = ${fruits?[0]}');
    print('fruits?[1] = ${fruits?[1]}');
    print('fruits?[2] = ${fruits?[2]}');
    print('fruits?[5] = ${fruits?.length != null && 5 < fruits!.length ? fruits[5] : null}'); // Безопасная проверка
    
    // Примеры с Map
    Map<String, int>? scores;
    print('\nMap<String, int>? scores = $scores;');
    print('scores?["math"] = ${scores?["math"]}');
    print('scores?["physics"] = ${scores?["physics"]}');
    
    scores = {"math": 95, "physics": 87, "chemistry": 92};
    print('\nscores = $scores;');
    print('scores?["math"] = ${scores?["math"]}');
    print('scores?["physics"] = ${scores?["physics"]}');
    print('scores?["biology"] = ${scores?["biology"]}'); // Несуществующий ключ
    
    print('\n3. ОПЕРАТОР ? (null-coalescing)');
    print('Возвращает левое значение, если оно не null, иначе правое значение\n');
    
    String? username;
    print('String? username = $username;');
    print('username ?? "Гость" = ${username ?? "Гость"}');
    print('username ?? "Пользователь" = ${username ?? "Пользователь"}');
    
    username = "admin";
    print('\nusername = "$username";');
    print('username ?? "Гость" = ${username ?? "Гость"}');
    print('username ?? "Пользователь" = ${username ?? "Пользователь"}');
    
    // Комбинированные примеры
    print('\n4. КОМБИНИРОВАННЫЕ ПРИМЕРЫ');
    print('Использование всех трех операторов вместе\n');
    
    Map<String, List<String>>? userData;
    print('Map<String, List<String>>? userData = $userData;');
    print('userData?["hobbies"]?[0] ?? "Нет хобби" = ${userData?["hobbies"]?[0] ?? "Нет хобби"}');
    print('userData?["hobbies"]?.length ?? 0 = ${userData?["hobbies"]?.length ?? 0}');
    
    userData = {"hobbies": ["чтение", "спорт", "музыка"]};
    print('\nuserData = $userData;');
    print('userData?["hobbies"]?[0] ?? "Нет хобби" = ${userData?["hobbies"]?[0] ?? "Нет хобби"}');
    print('userData?["hobbies"]?.length ?? 0 = ${userData?["hobbies"]?.length ?? 0}');
    print('userData?["hobbies"]?[1]?.toUpperCase() ?? "НЕИЗВЕСТНО" = ${userData?["hobbies"]?[1]?.toUpperCase() ?? "НЕИЗВЕСТНО"}');
    
    // Практические примеры из реальной жизни
    print('\n5. ПРАКТИЧЕСКИЕ ПРИМЕРЫ ИЗ РЕАЛЬНОЙ ЖИЗНИ');
    print('Примеры использования в Flutter приложениях\n');
    
    // Пример с пользователем
    Map<String, dynamic>? user;
    print('Map<String, dynamic>? user = $user;');
    print('Имя пользователя: ${user?["name"] ?? "Неизвестно"}');
    print('Возраст: ${user?["age"] ?? 0}');
    print('Email: ${user?["email"]?.toString().toLowerCase() ?? "Не указан"}');
    
    user = {"name": "Анна", "age": 28, "email": "ANNA@EXAMPLE.COM"};
    print('\nuser = $user;');
    print('Имя пользователя: ${user?["name"] ?? "Неизвестно"}');
    print('Возраст: ${user?["age"] ?? 0}');
    print('Email: ${user?["email"]?.toString().toLowerCase() ?? "Не указан"}');
    
    // Пример с настройками приложения
    Map<String, dynamic>? settings;
    print('\nMap<String, dynamic>? settings = $settings;');
    print('Тема: ${settings?["theme"] ?? "светлая"}');
    print('Язык: ${settings?["language"] ?? "ru"}');
    print('Уведомления: ${settings?["notifications"]?.toString() ?? "включены"}');
    
    settings = {"theme": "dark", "language": "en", "notifications": true};
    print('\nsettings = $settings;');
    print('Тема: ${settings?["theme"] ?? "светлая"}');
    print('Язык: ${settings?["language"] ?? "ru"}');
    print('Уведомления: ${settings?["notifications"]?.toString() ?? "включены"}');
    
    // Пример с API ответом
    Map<String, dynamic>? apiResponse;
    print('\nMap<String, dynamic>? apiResponse = $apiResponse;');
    print('Статус: ${apiResponse?["status"] ?? "неизвестен"}');
    print('Данные: ${apiResponse?["data"]?.toString() ?? "нет данных"}');
    print('Ошибка: ${apiResponse?["error"]?.toString() ?? "нет ошибок"}');
    
    apiResponse = {"status": "success", "data": {"users": 150}, "error": null};
    print('\napiResponse = $apiResponse;');
    print('Статус: ${apiResponse?["status"] ?? "неизвестен"}');
    print('Данные: ${apiResponse?["data"]?.toString() ?? "нет данных"}');
    print('Ошибка: ${apiResponse?["error"]?.toString() ?? "нет ошибок"}');
  }
}
