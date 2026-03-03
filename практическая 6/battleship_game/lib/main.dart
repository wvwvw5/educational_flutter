import 'dart:async';
import 'dart:io';
import 'game_logic.dart';
import 'game_board.dart';
import 'ship.dart';
import 'statistics.dart';
import 'game_event_stream.dart';

/// Точка входа — async main для работы с Future/Stream/Isolate
Future<void> main() async {
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║       🚢 ИГРА "МОРСКОЙ БОЙ" (Async Edition) 🚢         ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print('');
  print('⚡ Версия с поддержкой Future, Stream и Isolate');
  print('');

  bool playAgain = true;
  while (playAgain) {
    // Future: проверка и загрузка предыдущей статистики
    await _showMainMenu();

    // Future: асинхронная настройка игры
    final game = await _setupGameAsync();
    if (game != null) {
      await _playGame(game);
      // Закрываем Stream и освобождаем ресурсы
      await game.dispose();
    }

    print('\n🔄 Хотите сыграть еще раз? (да/нет): ');
    final answer = stdin.readLineSync()?.toLowerCase();
    playAgain =
        answer == 'да' || answer == 'yes' || answer == 'y' || answer == 'д';
  }

  print('\n👋 Спасибо за игру! До свидания!');
}

/// Главное меню с загрузкой статистики (Future)
///
/// Использует Future для асинхронной проверки существования
/// файлов и чтения содержимого последней игры.
Future<void> _showMainMenu() async {
  // Future<bool>: асинхронная проверка наличия сохранённой статистики
  final hasStats = await GameStatistics.hasStatistics('game_statistics');

  if (hasStats) {
    print('📂 Найдена статистика предыдущих игр!');
    print('   Хотите просмотреть? (да/нет): ');
    final answer = stdin.readLineSync()?.toLowerCase();

    if (answer == 'да' || answer == 'yes' || answer == 'y' || answer == 'д') {
      print('\n⏳ Загрузка статистики...');
      // Future<String?>: асинхронное чтение файла
      final stats = await GameStatistics.loadLastStatistics('game_statistics');
      if (stats != null) {
        print('\n📊 Статистика последней игры:');
        print(stats);
      } else {
        print('❌ Не удалось загрузить статистику.');
      }
      print('');
    }
  }
}

/// Асинхронная настройка игры (Future + Stream)
///
/// Использует:
/// - async/await для инициализации
/// - Future.delayed в placeShipsRandomlyAsync для прогресс-бара
/// - Stream подписку для уведомлений об уничтожении кораблей
Future<BattleshipGame?> _setupGameAsync() async {
  // Выбор режима игры
  print('📋 ВЫБОР РЕЖИМА ИГРЫ:');
  print('1. 🆚 Игра против друга');
  print('2. 🤖 Игра против ИИ');
  print('0. 🚪 Выход');
  print('\nВыберите режим (0-2): ');

  final modeInput = stdin.readLineSync();
  final mode = int.tryParse(modeInput ?? '');

  if (mode == 0) return null;
  if (mode != 1 && mode != 2) {
    print('❌ Неверный выбор режима!');
    return null;
  }

  // Выбор размера поля
  print('\n📏 Введите размер поля (от 5 до 10, рекомендуется 10): ');
  final sizeInput = stdin.readLineSync();
  final size = int.tryParse(sizeInput ?? '');

  final modeName = mode == 2 ? 'Игра против ИИ' : 'Игра против друга';
  final boardSize = (size != null && size >= 5 && size <= 10) ? size : 10;

  if (size == null || size < 5 || size > 10) {
    print('❌ Неверный размер поля! Используется размер 10.');
  }

  final shipSizes = _getShipSizes(boardSize);
  final game = BattleshipGame(boardSize, shipSizes);

  // Future: асинхронная инициализация (создание поля + запуск Stream логирования)
  await game.initializeAsync(mode == 2, modeName);

  // Future: асинхронное размещение кораблей с прогресс-баром
  print('\n🚢 Размещение кораблей...');
  print('⏳ Размещаем корабли игрока 1...');
  if (!await game.placeShipsRandomlyAsync(game.player1Board!, 1)) {
    print('❌ Ошибка размещения кораблей игрока 1!');
    return null;
  }

  print('⏳ Размещаем корабли игрока 2...');
  if (!await game.placeShipsRandomlyAsync(game.player2Board!, 2)) {
    print('❌ Ошибка размещения кораблей игрока 2!');
    return null;
  }

  print('✅ Корабли размещены!');

  // Stream: подписка на уничтожение кораблей для уведомлений
  // whereType<T>() — фильтрация потока по типу события
  game.eventStream.destroyedEvents.listen((event) {
    print('  🔔 [Stream] ${event.description}');
  });

  print('\n🎮 Начинаем игру!\n');
  return game;
}

List<int> _getShipSizes(int boardSize) {
  if (boardSize >= 10) {
    return [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
  } else if (boardSize >= 8) {
    return [3, 2, 2, 1, 1, 1];
  } else {
    return [2, 2, 1, 1];
  }
}

/// Основной игровой цикл с поддержкой async/await, Stream и Isolate
Future<void> _playGame(BattleshipGame game) async {
  int currentPlayer = 1;

  while (true) {
    _displayGameState(game, currentPlayer);

    // Проверяем победу
    if (game.checkWin(currentPlayer == 1 ? 2 : 1)) {
      _displayGameState(game, currentPlayer);
      _showWinMessage(game, currentPlayer);
      game.endGame();
      _showStatistics(game);
      await _saveGameStatistics(game);

      // Показываем лог событий, собранных через Stream
      _showEventLog(game);
      break;
    }

    // Ход игрока
    if (currentPlayer == 1 || !game.isPlayerVsAI) {
      // Предлагаем анализ поля через Isolate
      print(
          '  💡 Введите "анализ" для анализа поля (Isolate) или координаты:');
      final input = stdin.readLineSync()?.trim();

      if (input?.toLowerCase() == 'анализ' ||
          input?.toLowerCase() == 'analysis') {
        // Isolate: запуск анализа поля в отдельном изоляте
        await _showBoardAnalysis(game, currentPlayer);
        continue;
      }

      final result = _playerTurn(game, currentPlayer, input);
      if (result == null) continue;

      if (result == ShotResult.miss) {
        // Stream: событие смены хода
        game.eventStream
            .addEvent(TurnChangeEvent(currentPlayer == 1 ? 2 : 1));
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        if (game.isPlayerVsAI && currentPlayer == 2) {
          print('\n🤖 Ход компьютера...');
        }
      } else if (result == ShotResult.hit || result == ShotResult.destroyed) {
        print('🎯 Вы попали! Ходите еще раз!\n');
      }
    } else {
      // Future + Isolate: асинхронный ход ИИ с вычислением в Isolate
      final aiMoveResult = await game.aiMoveAsync();
      if (aiMoveResult != null) {
        final aiShot = aiMoveResult['shot'] as Point;
        final result = aiMoveResult['result'] as ShotResult;

        print(
            '🤖 Компьютер стреляет: ${_coordsToLetter(aiShot.row)}${aiShot.col + 1}');
        print('${game.getShotMessage(result)}\n');

        if (result == ShotResult.miss) {
          game.eventStream.addEvent(TurnChangeEvent(1));
          currentPlayer = 1;
          print('👤 Ваш ход!\n');
        } else if (result == ShotResult.hit ||
            result == ShotResult.destroyed) {
          print('🤖 Компьютер попал! Ходит еще раз...\n');
          // Future.delayed вместо sleep — не блокирует event loop
          await Future.delayed(Duration(milliseconds: 500));
        } else {
          currentPlayer = 1;
          print('👤 Ваш ход!\n');
        }
      }
    }
  }
}

/// Показать анализ поля (Isolate)
///
/// Запускает тяжёлые вычисления в отдельном Isolate через Isolate.run().
/// Результат возвращается через Future — основной поток не блокируется.
Future<void> _showBoardAnalysis(BattleshipGame game, int player) async {
  print('\n🔍 Запуск анализа поля в отдельном изоляте...');

  final analysis = await game.analyzeCurrentBoard(player);

  print('\n╔═══════════════════════════════════════╗');
  print('║      🔍 АНАЛИЗ ПОЛЯ (Isolate)        ║');
  print('╠═══════════════════════════════════════╣');
  print(
      '║ 📊 Покрытие: ${analysis.coveragePercent.toStringAsFixed(1)}%'
          .padRight(40) +
      '║');
  print(
      '║ 🎯 Точность: ${analysis.hitRate.toStringAsFixed(1)}%'.padRight(40) +
      '║');
  print(
      '║ ❓ Неисследовано: ${analysis.unexploredCells} клеток'.padRight(40) +
      '║');
  print(
      '║ 🚢 Осталось кораблей: ~${analysis.estimatedShipsRemaining}'
          .padRight(40) +
      '║');
  print(
      '║ 📈 Прогресс: ${(analysis.gameProgress * 100).toStringAsFixed(0)}%'
          .padRight(40) +
      '║');
  print('╠═══════════════════════════════════════╣');
  print('║ 💡 ${analysis.recommendation}'.padRight(40) + '║');
  print('╚═══════════════════════════════════════╝\n');
}

ShotResult? _playerTurn(BattleshipGame game, int player, [String? preInput]) {
  final playerName =
      player == 1 ? 'Игрок 1' : (game.isPlayerVsAI ? 'Вы' : 'Игрок 2');

  String? input = preInput;
  if (input == null || input.isEmpty) {
    print('🎯 Ход $playerName');
    print('Введите координаты (например: A1, B5): ');
    input = stdin.readLineSync()?.trim().toUpperCase();
  } else {
    input = input.toUpperCase();
  }

  if (input == null || input.isEmpty) {
    print('❌ Пустой ввод! Попробуйте снова.\n');
    return null;
  }

  final coords = _parseCoordinates(input);
  if (coords == null) {
    print(
        '❌ Некорректный формат координат! Используйте формат: A1, B5 и т.д.\n');
    return null;
  }

  final result = game.playerMove(coords.row, coords.col, player);
  if (result != null) {
    print('${game.getShotMessage(result)}\n');
    if (result == ShotResult.invalid || result == ShotResult.alreadyShot) {
      return null;
    }
  } else {
    print('❌ Ошибка при выполнении выстрела!\n');
    return null;
  }

  return result;
}

Point? _parseCoordinates(String input) {
  if (input.length < 2) return null;

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

  final myBoard =
      viewingPlayer == 1 ? game.player1Board! : game.player2Board!;
  final enemyBoard =
      viewingPlayer == 1 ? game.player2Board! : game.player1Board!;

  _displayBoards(myBoard, enemyBoard, viewingPlayer == 1);
  _displayStatistics(game, viewingPlayer);
}

void _displayBoards(
    GameBoard myBoard, GameBoard enemyBoard, bool showMyShips) {
  final size = myBoard.size;

  stdout.write('   ');
  for (int i = 0; i < size; i++) {
    stdout.write('${String.fromCharCode('A'.codeUnitAt(0) + i)} ');
  }
  stdout.write('    ');
  for (int i = 0; i < size; i++) {
    stdout.write('${String.fromCharCode('A'.codeUnitAt(0) + i)} ');
  }
  print('');

  for (int row = 0; row < size; row++) {
    stdout.write('${row + 1}'.padLeft(2) + ' ');
    for (int col = 0; col < size; col++) {
      final cell = myBoard.getCell(row, col);
      stdout.write(_getCellSymbol(cell, showMyShips));
    }

    stdout.write('   ${row + 1}'.padLeft(2) + ' ');
    for (int col = 0; col < size; col++) {
      final point = Point(row, col);
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
    print('  👤 Игрок 1:');
    print(
        '    🎯 Разрушено кораблей противника: ${stats.player1ShipsDestroyed}');
    print('    💔 Потеряно кораблей: ${stats.player1ShipsLost}');
    print(
        '    🚢 Осталось кораблей на поле: ${stats.getPlayer1RemainingShips()}/${stats.totalShipsPlayer1}');
    print('    ✅ Попаданий: ${stats.player1Hits}');
    print('    ❌ Промахов: ${stats.player1Misses}');
    print(
        '    📊 Точность: ${stats.getPlayer1Accuracy().toStringAsFixed(1)}%');
  }
  if (!game.isPlayerVsAI || player == 2) {
    print('  ${game.isPlayerVsAI ? "🤖 Компьютер" : "👤 Игрок 2"}:');
    print(
        '    🎯 Разрушено кораблей противника: ${stats.player2ShipsDestroyed}');
    print('    💔 Потеряно кораблей: ${stats.player2ShipsLost}');
    print(
        '    🚢 Осталось кораблей на поле: ${stats.getPlayer2RemainingShips()}/${stats.totalShipsPlayer2}');
    print('    ✅ Попаданий: ${stats.player2Hits}');
    print('    ❌ Промахов: ${stats.player2Misses}');
    print(
        '    📊 Точность: ${stats.getPlayer2Accuracy().toStringAsFixed(1)}%');
  }
  print('  🎯 Всего выстрелов: ${stats.totalShots}');
  print('  ✅ Всего попаданий: ${stats.player1Hits + stats.player2Hits}');
  print('  ❌ Всего промахов: ${stats.player1Misses + stats.player2Misses}');
  final duration = stats.getGameDuration();
  if (duration != null) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    print('  ⏱️  Время игры: ${minutes}м ${seconds}с');
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

/// Показывает лог событий, собранных через Stream
void _showEventLog(BattleshipGame game) {
  final events = game.eventStream.eventLog;
  print('\n📋 ЛОГ СОБЫТИЙ (Stream, ${events.length} событий):');
  print('${'─' * 60}');

  // Показываем последние 15 событий
  final startIndex = events.length > 15 ? events.length - 15 : 0;
  for (int i = startIndex; i < events.length; i++) {
    print('  ${events[i]}');
  }
  if (startIndex > 0) {
    print(
        '  ... и ещё $startIndex событий (полный лог в файле game_logs/)');
  }
  print('${'─' * 60}\n');
}

/// Сохраняет статистику (Future — асинхронная запись в файл)
Future<void> _saveGameStatistics(BattleshipGame game) async {
  final statsDir = 'game_statistics';
  print('\n💾 Сохранение статистики...');
  await game.saveStatistics(statsDir);
}
