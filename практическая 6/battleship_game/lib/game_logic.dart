import 'dart:io' show stdout;
import 'dart:math';
import 'game_board.dart';
import 'ship.dart';
import 'ai.dart';
import 'statistics.dart';
import 'game_event_stream.dart';
import 'isolate_ai.dart';
import 'board_analyzer.dart';

/// Основной класс игры с поддержкой асинхронных вызовов.
///
/// В этой версии добавлены:
/// - Future: асинхронная инициализация и размещение кораблей
/// - Stream: потоковые игровые события через GameEventStream
/// - Isolate: вычисление хода ИИ и анализ поля в отдельных изолятах
class BattleshipGame {
  final int boardSize;
  final List<int> shipSizes;
  GameBoard? player1Board;
  GameBoard? player2Board;
  AI? ai;
  GameStatistics statistics = GameStatistics();
  bool isPlayerVsAI = false;
  int currentPlayer = 1;
  Random random = Random();

  /// Stream событий игры (broadcast — несколько подписчиков)
  final GameEventStream eventStream = GameEventStream();

  BattleshipGame(this.boardSize, this.shipSizes);

  /// Асинхронная инициализация игры (Future)
  ///
  /// Использует Future.delayed для имитации загрузки ресурсов.
  /// В реальном приложении здесь могла бы быть загрузка данных
  /// из сети или базы данных.
  Future<void> initializeAsync(bool vsAI, String modeName) async {
    print('⏳ Инициализация игры...');

    // Future.delayed — имитация асинхронной загрузки конфигурации
    await Future.delayed(Duration(milliseconds: 300));

    isPlayerVsAI = vsAI;
    player1Board = GameBoard(boardSize);
    player2Board = GameBoard(boardSize);

    if (vsAI) {
      ai = AI(player2Board!, random);
    }

    statistics.startGame();
    statistics.gameMode = modeName;
    statistics.boardSize = boardSize;

    // Запускаем асинхронное логирование событий в файл через Stream
    await eventStream.startFileLogging('game_logs');

    print('✅ Игра инициализирована!');
  }

  /// Синхронная инициализация (для обратной совместимости)
  void initialize(bool vsAI, String modeName) {
    isPlayerVsAI = vsAI;
    player1Board = GameBoard(boardSize);
    player2Board = GameBoard(boardSize);
    if (vsAI) {
      ai = AI(player2Board!, random);
    }
    statistics.startGame();
    statistics.gameMode = modeName;
    statistics.boardSize = boardSize;
  }

  /// Асинхронное размещение кораблей с прогрессом (Future)
  ///
  /// Каждый корабль размещается с задержкой через Future.delayed,
  /// что позволяет показывать прогресс-бар размещения.
  /// Событие ShipPlacedEvent отправляется в Stream.
  Future<bool> placeShipsRandomlyAsync(GameBoard board, int player) async {
    final sortedShips = List<int>.from(shipSizes)
      ..sort((a, b) => b.compareTo(a));

    for (int i = 0; i < sortedShips.length; i++) {
      final shipSize = sortedShips[i];

      // Future.delayed — асинхронная задержка для визуального прогресса
      await Future.delayed(Duration(milliseconds: 150));

      if (!board.placeShipRandom(shipSize, random)) {
        return false;
      }

      // Отправляем событие размещения в Stream
      eventStream.addEvent(ShipPlacedEvent(player, shipSize));

      // Показываем прогресс-бар
      final progress = ((i + 1) / sortedShips.length * 100).toInt();
      stdout.write(
          '\r  ⏳ Игрок $player: размещено ${i + 1}/${sortedShips.length} кораблей [${'█' * (progress ~/ 10)}${'░' * (10 - progress ~/ 10)}] $progress%');
    }
    print(''); // Новая строка после прогресс-бара

    statistics.setTotalShips(player, board.ships.length);
    return true;
  }

  /// Синхронная расстановка (для обратной совместимости)
  bool placeShipsRandomly(GameBoard board, int player) {
    final sortedShips = List<int>.from(shipSizes)
      ..sort((a, b) => b.compareTo(a));
    for (final shipSize in sortedShips) {
      if (!board.placeShipRandom(shipSize, random)) {
        return false;
      }
    }
    statistics.setTotalShips(player, board.ships.length);
    return true;
  }

  /// Размещает корабли вручную (для будущего расширения)
  bool placeShipsManually(GameBoard board, int player) {
    return placeShipsRandomly(board, player);
  }

  /// Обрабатывает ход игрока и отправляет события в Stream
  ShotResult? playerMove(int row, int col, int player) {
    if (player == 1) {
      final result = player2Board!.shoot(row, col);
      if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
        statistics.updateShot(1, result);
        statistics.updateShipsLost(2, player2Board!.getDestroyedShips());

        // Stream: отправляем событие выстрела
        eventStream.addEvent(ShotEvent(1, row, col, result));
        if (result == ShotResult.destroyed) {
          final destroyedShip =
              player2Board!.ships.where((s) => s.isDestroyed).last;
          eventStream.addEvent(ShipDestroyedEvent(2, destroyedShip.length));
        }
      }
      return result;
    } else {
      final result = player1Board!.shoot(row, col);
      if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
        statistics.updateShot(2, result);
        statistics.updateShipsLost(1, player1Board!.getDestroyedShips());

        eventStream.addEvent(ShotEvent(2, row, col, result));
        if (result == ShotResult.destroyed) {
          final destroyedShip =
              player1Board!.ships.where((s) => s.isDestroyed).last;
          eventStream.addEvent(ShipDestroyedEvent(1, destroyedShip.length));
        }
      }
      return result;
    }
  }

  /// Асинхронный ход ИИ с вычислением в Isolate
  ///
  /// Подготавливает сериализуемые данные (List<List<int>>),
  /// передаёт их в Isolate.run() для тяжёлых вычислений,
  /// получает результат через Future.
  Future<Map<String, dynamic>?> aiMoveAsync() async {
    if (ai == null) return null;

    // Подготавливаем данные для Isolate (только примитивные типы)
    final boardState = _boardToIntList(player1Board!);
    final hitPositions =
        player1Board!.hitShots.map((p) => [p.row, p.col]).toList();
    final missPositions =
        player1Board!.missedShots.map((p) => [p.row, p.col]).toList();

    final aiData = AiComputeData(
      boardSize: boardSize,
      boardState: boardState,
      hitPositions: hitPositions,
      missPositions: missPositions,
      lastHitRow: ai!.lastHit?.row,
      lastHitCol: ai!.lastHit?.col,
    );

    print('  🧠 ИИ анализирует поле в отдельном изоляте...');

    // Isolate.run() — вычисления в отдельном потоке
    final computeResult = await computeAiMoveInIsolate(aiData);

    print(
        '  💡 Уверенность: ${(computeResult.confidence * 100).toInt()}% — ${computeResult.reasoning}');

    // Применяем результат Isolate
    final shot = Point(computeResult.row, computeResult.col);
    final result = player1Board!.shoot(shot.row, shot.col);
    ai!.updateAfterShot(shot, result);

    if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
      statistics.updateShot(2, result);
      statistics.updateShipsLost(1, player1Board!.getDestroyedShips());

      eventStream.addEvent(ShotEvent(2, shot.row, shot.col, result));
      if (result == ShotResult.destroyed) {
        final destroyedShip =
            player1Board!.ships.where((s) => s.isDestroyed).last;
        eventStream.addEvent(ShipDestroyedEvent(1, destroyedShip.length));
      }
    }

    return {'shot': shot, 'result': result};
  }

  /// Синхронный ход ИИ (для обратной совместимости)
  Map<String, dynamic>? aiMove() {
    if (ai == null) return null;
    final shot = ai!.makeMove();
    final result = player1Board!.shoot(shot.row, shot.col);
    ai!.updateAfterShot(shot, result);
    if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
      statistics.updateShot(2, result);
      statistics.updateShipsLost(1, player1Board!.getDestroyedShips());
    }
    return {'shot': shot, 'result': result};
  }

  /// Анализ поля противника в Isolate (для подсказки игроку)
  ///
  /// Запускает BoardAnalysisData в отдельном Isolate через Isolate.run(),
  /// возвращает Future<BoardAnalysisResult> с рекомендацией.
  Future<BoardAnalysisResult> analyzeCurrentBoard(int player) async {
    final targetBoard = player == 1 ? player2Board! : player1Board!;

    final data = BoardAnalysisData(
      boardSize: boardSize,
      boardState: _boardToIntList(targetBoard),
      totalShips: targetBoard.ships.length,
      destroyedShips: targetBoard.getDestroyedShips(),
      hits: player == 1 ? statistics.player1Hits : statistics.player2Hits,
      misses: player == 1 ? statistics.player1Misses : statistics.player2Misses,
    );

    final result = await analyzeBoardInIsolate(data);

    // Отправляем событие анализа в Stream
    eventStream.addEvent(AnalysisEvent(result.recommendation));

    return result;
  }

  /// Конвертирует GameBoard в List<List<int>> для передачи в Isolate
  /// (Isolate не может работать с произвольными объектами)
  List<List<int>> _boardToIntList(GameBoard board) {
    return List.generate(board.size, (r) {
      return List.generate(board.size, (c) {
        switch (board.getCell(r, c)) {
          case CellState.empty:
            return 0;
          case CellState.ship:
            return 1;
          case CellState.hit:
            return 2;
          case CellState.miss:
            return 3;
        }
      });
    });
  }

  /// Проверяет победу
  bool checkWin(int player) {
    if (player == 1) {
      return player2Board!.allShipsDestroyed();
    } else {
      return player1Board!.allShipsDestroyed();
    }
  }

  /// Получает сообщение о результате выстрела
  String getShotMessage(ShotResult result) {
    switch (result) {
      case ShotResult.hit:
        return '🎯 Попадание!';
      case ShotResult.miss:
        return '💨 Промах!';
      case ShotResult.destroyed:
        return '💥 Корабль потоплен!';
      case ShotResult.invalid:
        return '❌ Некорректные координаты!';
      case ShotResult.alreadyShot:
        return '⚠️ Вы уже стреляли сюда!';
    }
  }

  /// Завершает игру и отправляет финальное событие в Stream
  void endGame() {
    statistics.endGame();
    statistics.updateShipsLost(1, player1Board!.getDestroyedShips());
    statistics.updateShipsLost(2, player2Board!.getDestroyedShips());

    final winner = player1Board!.allShipsDestroyed() ? 2 : 1;
    eventStream.addEvent(GameOverEvent(winner, statistics.totalShots));
  }

  /// Сохраняет статистику в файл (Future)
  Future<void> saveStatistics(String directoryPath) async {
    await statistics.saveToFile(directoryPath);
  }

  /// Закрывает Stream и освобождает ресурсы
  Future<void> dispose() async {
    await eventStream.dispose();
  }
}
