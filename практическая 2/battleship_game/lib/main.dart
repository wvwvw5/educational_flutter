import 'dart:io';
import 'game_logic.dart';
import 'game_board.dart';
import 'ship.dart';

void main() {
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║          🚢 ИГРА "МОРСКОЙ БОЙ" 🚢                      ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print('');

  bool playAgain = true;
  while (playAgain) {
    final game = _setupGame();
    if (game != null) {
      _playGame(game);
    }

    print('\n🔄 Хотите сыграть еще раз? (да/нет): ');
    final answer = stdin.readLineSync()?.toLowerCase();
    playAgain = answer == 'да' || answer == 'yes' || answer == 'y' || answer == 'д';
  }

  print('\n👋 Спасибо за игру! До свидания!');
}

BattleshipGame? _setupGame() {
  // Выбор режима игры
  print('📋 ВЫБОР РЕЖИМА ИГРЫ:');
  print('1. 🆚 Игра против друга');
  print('2. 🤖 Игра против ИИ');
  print('0. 🚪 Выход');
  print('\nВыберите режим (0-2): ');

  final modeInput = stdin.readLineSync();
  final mode = int.tryParse(modeInput ?? '');

  if (mode == 0) {
    return null;
  }

  if (mode != 1 && mode != 2) {
    print('❌ Неверный выбор режима!');
    return null;
  }

  // Выбор размера поля
  print('\n📏 Введите размер поля (от 5 до 10, рекомендуется 10): ');
  final sizeInput = stdin.readLineSync();
  final size = int.tryParse(sizeInput ?? '');

  if (size == null || size < 5 || size > 10) {
    print('❌ Неверный размер поля! Используется размер 10.');
    final game = BattleshipGame(10, _getShipSizes(10));
    game.initialize(mode == 2);
    return game;
  }

  final shipSizes = _getShipSizes(size);
  final game = BattleshipGame(size, shipSizes);
  game.initialize(mode == 2);

  // Размещение кораблей
  print('\n🚢 Размещение кораблей...');
  print('⏳ Размещаем корабли игрока 1...');
  if (!game.placeShipsRandomly(game.player1Board!)) {
    print('❌ Ошибка размещения кораблей игрока 1!');
    return null;
  }

  print('⏳ Размещаем корабли игрока 2...');
  if (!game.placeShipsRandomly(game.player2Board!)) {
    print('❌ Ошибка размещения кораблей игрока 2!');
    return null;
  }

  print('✅ Корабли размещены!');
  print('\n🎮 Начинаем игру!\n');

  return game;
}

List<int> _getShipSizes(int boardSize) {
  // Стандартная конфигурация кораблей для Морского боя
  if (boardSize >= 10) {
    return [4, 3, 3, 2, 2, 2, 1, 1, 1, 1]; // 1x4, 2x3, 3x2, 4x1
  } else if (boardSize >= 8) {
    return [3, 2, 2, 1, 1, 1]; // Упрощенная конфигурация
  } else {
    return [2, 2, 1, 1]; // Минимальная конфигурация
  }
}

void _playGame(BattleshipGame game) {
  int currentPlayer = 1;

  while (true) {
    // Показываем поле текущего игрока
    _displayGameState(game, currentPlayer);

    // Проверяем победу
    if (game.checkWin(currentPlayer == 1 ? 2 : 1)) {
      _displayGameState(game, currentPlayer);
      _showWinMessage(game, currentPlayer);
      game.endGame();
      _showStatistics(game);
      break;
    }

    // Ход игрока
    if (currentPlayer == 1 || !game.isPlayerVsAI) {
      final result = _playerTurn(game, currentPlayer);
      if (result == null) continue; // Повтор хода при ошибке

      if (result == ShotResult.miss) {
        // Переход хода
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        if (game.isPlayerVsAI && currentPlayer == 2) {
          print('\n🤖 Ход компьютера...');
          sleep(Duration(seconds: 1));
        }
      } else if (result == ShotResult.hit || result == ShotResult.destroyed) {
        // Игрок продолжает ход
        print('🎯 Вы попали! Ходите еще раз!\n');
      }
    } else {
      // Ход ИИ
      final aiShot = game.aiMove();
      if (aiShot != null) {
        final result = game.player1Board!.shoot(aiShot.row, aiShot.col);
        print('🤖 Компьютер стреляет: ${_coordsToLetter(aiShot.row)}${aiShot.col + 1}');
        print('${game.getShotMessage(result)}\n');

        if (result == ShotResult.miss) {
          currentPlayer = 1;
          print('👤 Ваш ход!\n');
        } else {
          print('🤖 Компьютер попал! Ходит еще раз...\n');
          sleep(Duration(seconds: 1));
        }
      }
    }
  }
}

ShotResult? _playerTurn(BattleshipGame game, int player) {
  final playerName = player == 1 ? 'Игрок 1' : (game.isPlayerVsAI ? 'Вы' : 'Игрок 2');
  print('🎯 Ход $playerName');
  print('Введите координаты (например: A1, B5): ');

  final input = stdin.readLineSync()?.trim().toUpperCase();
  if (input == null || input.isEmpty) {
    print('❌ Пустой ввод! Попробуйте снова.\n');
    return null;
  }

  // Парсинг координат
  final coords = _parseCoordinates(input);
  if (coords == null) {
    print('❌ Некорректный формат координат! Используйте формат: A1, B5 и т.д.\n');
    return null;
  }

  final result = game.playerMove(coords.row, coords.col, player);
  if (result != null) {
    print('${game.getShotMessage(result)}\n');
    if (result == ShotResult.invalid || result == ShotResult.alreadyShot) {
      return null; // Повтор хода
    }
  } else {
    print('❌ Ошибка при выполнении выстрела!\n');
    return null;
  }

  return result;
}

Point? _parseCoordinates(String input) {
  if (input.length < 2) return null;

  // Извлекаем букву и число
  final letter = input[0];
  final numberStr = input.substring(1);

  if (letter.codeUnitAt(0) < 'A'.codeUnitAt(0) ||
      letter.codeUnitAt(0) > 'Z'.codeUnitAt(0)) {
    return null;
  }

  final row = letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
  final col = int.tryParse(numberStr);

  if (col == null || col < 1) return null;

  return Point(row, col - 1);
}

String _coordsToLetter(int row) {
  return String.fromCharCode('A'.codeUnitAt(0) + row);
}

void _displayGameState(BattleshipGame game, int viewingPlayer) {
  print('\n${'=' * 70}');
  if (viewingPlayer == 1) {
    print('👤 ВАШЕ ПОЛЕ                    🎯 ПОЛЕ ПРОТИВНИКА');
  } else {
    if (game.isPlayerVsAI) {
      print('🤖 ПОЛЕ КОМПЬЮТЕРА              🎯 ВАШЕ ПОЛЕ (для компьютера)');
    } else {
      print('👤 ПОЛЕ ИГРОКА 2                🎯 ПОЛЕ ИГРОКА 1');
    }
  }
  print('${'=' * 70}\n');

  final myBoard = viewingPlayer == 1 ? game.player1Board! : game.player2Board!;
  final enemyBoard = viewingPlayer == 1 ? game.player2Board! : game.player1Board!;

  _displayBoards(myBoard, enemyBoard, viewingPlayer == 1);
  _displayStatistics(game, viewingPlayer);
}

void _displayBoards(GameBoard myBoard, GameBoard enemyBoard, bool showMyShips) {
  final size = myBoard.size;

  // Заголовки
  stdout.write('   ');
  for (int i = 0; i < size; i++) {
    stdout.write('${String.fromCharCode('A'.codeUnitAt(0) + i)} ');
  }
  stdout.write('    ');
  for (int i = 0; i < size; i++) {
    stdout.write('${String.fromCharCode('A'.codeUnitAt(0) + i)} ');
  }
  print('');

  // Строки полей
  for (int row = 0; row < size; row++) {
    // Мое поле
    stdout.write('${row + 1}'.padLeft(2) + ' ');
    for (int col = 0; col < size; col++) {
      final cell = myBoard.getCell(row, col);
      stdout.write(_getCellSymbol(cell, showMyShips));
    }

    // Поле противника
    stdout.write('   ${row + 1}'.padLeft(2) + ' ');
    for (int col = 0; col < size; col++) {
      final point = Point(row, col);
      // На поле противника показываем только попадания и промахи
      if (enemyBoard.hitShots.contains(point)) {
        stdout.write('💥 ');
      } else if (enemyBoard.missedShots.contains(point)) {
        stdout.write('💨 ');
      } else {
        stdout.write('🌊 ');
      }
    }
    print('');
  }

  print('');
  _printLegend(showMyShips);
}

String _getCellSymbol(CellState cell, bool showShips) {
  switch (cell) {
    case CellState.empty:
      return '🌊 ';
    case CellState.ship:
      return showShips ? '🚢 ' : '🌊 ';
    case CellState.hit:
      return '💥 ';
    case CellState.miss:
      return '💨 ';
  }
}

void _printLegend(bool showShips) {
  print('Легенда:');
  if (showShips) {
    print('  🚢 - Корабль');
  }
  print('  💥 - Попадание');
  print('  💨 - Промах');
  print('  🌊 - Пустая клетка');
  print('');
}

void _displayStatistics(BattleshipGame game, int player) {
  final stats = game.statistics;
  print('📊 СТАТИСТИКА:');
  if (player == 1 || !game.isPlayerVsAI) {
    print('  Игрок 1:');
    print('    Попаданий: ${stats.player1Hits}');
    print('    Промахов: ${stats.player1Misses}');
    print('    Потоплено кораблей: ${stats.player1ShipsDestroyed}');
    print('    Точность: ${stats.getPlayer1Accuracy().toStringAsFixed(1)}%');
  }
  if (!game.isPlayerVsAI || player == 2) {
    print('  ${game.isPlayerVsAI ? "Компьютер" : "Игрок 2"}:');
    print('    Попаданий: ${stats.player2Hits}');
    print('    Промахов: ${stats.player2Misses}');
    print('    Потоплено кораблей: ${stats.player2ShipsDestroyed}');
    print('    Точность: ${stats.getPlayer2Accuracy().toStringAsFixed(1)}%');
  }
  print('  Всего выстрелов: ${stats.totalShots}');
  final duration = stats.getGameDuration();
  if (duration != null) {
    print('  Время игры: ${duration} сек');
  }
  print('');
}

void _showWinMessage(BattleshipGame game, int winner) {
  print('\n${'=' * 70}');
  print('🎉🎉🎉 ПОЗДРАВЛЯЕМ! 🎉🎉🎉');
  if (winner == 1) {
    print('🏆 ПОБЕДИТЕЛЬ: ${game.isPlayerVsAI ? "ВЫ" : "ИГРОК 1"}!');
  } else {
    print('🏆 ПОБЕДИТЕЛЬ: ${game.isPlayerVsAI ? "КОМПЬЮТЕР" : "ИГРОК 2"}!');
  }
  print('${'=' * 70}\n');
}

void _showStatistics(BattleshipGame game) {
  print('📊 ФИНАЛЬНАЯ СТАТИСТИКА:');
  _displayStatistics(game, 1);
}