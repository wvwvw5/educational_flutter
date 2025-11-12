import 'dart:math';
import 'game_board.dart';
import 'ship.dart';
import 'ai.dart';
import 'statistics.dart';

/// Основной класс игры
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

  BattleshipGame(this.boardSize, this.shipSizes);

  /// Инициализирует игру
  void initialize(bool vsAI) {
    isPlayerVsAI = vsAI;
    player1Board = GameBoard(boardSize);
    player2Board = GameBoard(boardSize);

    if (vsAI) {
      ai = AI(player2Board!, random);
    }

    statistics.startGame();
  }

  /// Размещает корабли случайно для игрока
  bool placeShipsRandomly(GameBoard board) {
    // Сортируем корабли по размеру (от больших к маленьким)
    final sortedShips = List<int>.from(shipSizes)..sort((a, b) => b.compareTo(a));

    for (final shipSize in sortedShips) {
      if (!board.placeShipRandom(shipSize, random)) {
        return false;
      }
    }
    return true;
  }

  /// Размещает корабли вручную (для будущего расширения)
  bool placeShipsManually(GameBoard board) {
    // В этой версии используем случайную расстановку
    return placeShipsRandomly(board);
  }

  /// Обрабатывает ход игрока
  ShotResult? playerMove(int row, int col, int player) {
    if (player == 1) {
      final result = player2Board!.shoot(row, col);
      if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
        statistics.updateShot(1, result);
      }
      return result;
    } else {
      final result = player1Board!.shoot(row, col);
      if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
        statistics.updateShot(2, result);
      }
      return result;
    }
  }

  /// Обрабатывает ход ИИ
  Point? aiMove() {
    if (ai == null) return null;
    final shot = ai!.makeMove();
    final result = player1Board!.shoot(shot.row, shot.col);
    ai!.updateAfterShot(shot, result);
    if (result != ShotResult.invalid && result != ShotResult.alreadyShot) {
      statistics.updateShot(2, result);
    }
    return shot;
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

  /// Завершает игру
  void endGame() {
    statistics.endGame();
  }
}
