import 'dart:io';

void main() {
  print('🎮 ДЕМОНСТРАЦИЯ ИГРЫ "КРЕСТИКИ-НОЛИКИ"');
  print('=' * 50);
  
  print('\n📋 ВОЗМОЖНОСТИ ИГРЫ:');
  print('✅ Оценка 3:');
  print('   • Запрос размера игрового поля');
  print('   • Поочередные ходы игроков X и O');
  print('   • Определение победителя и ничьей');
  
  print('\n✅ Оценка 4:');
  print('   • Случайный выбор первого игрока');
  print('   • Возможность новой игры без выхода');
  
  print('\n✅ Оценка 5:');
  print('   • Режим игры против друга');
  print('   • Режим игры против робота');
  print('   • Умный ИИ для робота');
  
  print('\n🎯 ДОПОЛНИТЕЛЬНЫЕ ВОЗМОЖНОСТИ:');
  print('   • Размер поля от 3x3 до 10x10');
  print('   • Красивый интерфейс с эмодзи');
  print('   • Подробные инструкции');
  print('   • Обработка ошибок ввода');
  
  print('\n🚀 КАК ЗАПУСТИТЬ:');
  print('   dart run lib/main.dart');
  print('   или');
  print('   ./run.sh (на macOS/Linux)');
  print('   run.bat (на Windows)');
  
  print('\n🎲 ПРИМЕР ИГРОВОГО ПОЛЯ 3x3:');
  print('   ' + '=' * 13);
  print('   | 1 | 2 | 3 |');
  print('   ' + '-' * 13);
  print(' 1 | X | · | O |');
  print('   ' + '-' * 13);
  print(' 2 | · | X | · |');
  print('   ' + '-' * 13);
  print(' 3 | O | · | X |');
  print('   ' + '=' * 13);
  
  print('\n🎮 Хотите запустить игру? (y/n): ');
  final input = stdin.readLineSync()?.trim().toLowerCase();
  
  if (input == 'y' || input == 'yes' || input == 'да') {
    print('\n🚀 Запускаем игру...\n');
    // Импортируем и запускаем основную игру
    Process.run('dart', ['run', 'lib/main.dart'], workingDirectory: Directory.current.path);
  } else {
    print('\n👋 До свидания! Запустите игру когда будете готовы!');
  }
}
