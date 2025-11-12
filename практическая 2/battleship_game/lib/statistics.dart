import 'game_board.dart';

/// Класс для хранения статистики игры
class GameStatistics {
  int player1Hits = 0;
  int player1Misses = 0;
  int player2Hits = 0;
  int player2Misses = 0;
  int player1ShipsDestroyed = 0;
  int player2ShipsDestroyed = 0;
  int totalShots = 0;
  DateTime? gameStartTime;
  DateTime? gameEndTime;

  /// Начинает отсчет времени игры
  void startGame() {
    gameStartTime = DateTime.now();
  }

  /// Заканчивает игру
  void endGame() {
    gameEndTime = DateTime.now();
  }

  /// Получает длительность игры в секундах
  int? getGameDuration() {
    if (gameStartTime == null || gameEndTime == null) return null;
    return gameEndTime!.difference(gameStartTime!).inSeconds;
  }

  /// Получает точность игрока 1
  double getPlayer1Accuracy() {
    final total = player1Hits + player1Misses;
    if (total == 0) return 0.0;
    return (player1Hits / total) * 100;
  }

  /// Получает точность игрока 2
  double getPlayer2Accuracy() {
    final total = player2Hits + player2Misses;
    if (total == 0) return 0.0;
    return (player2Hits / total) * 100;
  }

  /// Обновляет статистику после выстрела
  void updateShot(int player, ShotResult result) {
    totalShots++;
    if (player == 1) {
      if (result == ShotResult.hit || result == ShotResult.destroyed) {
        player1Hits++;
        if (result == ShotResult.destroyed) {
          player1ShipsDestroyed++;
        }
      } else {
        player1Misses++;
      }
    } else {
      if (result == ShotResult.hit || result == ShotResult.destroyed) {
        player2Hits++;
        if (result == ShotResult.destroyed) {
          player2ShipsDestroyed++;
        }
      } else {
        player2Misses++;
      }
    }
  }

  /// Сбрасывает статистику
  void reset() {
    player1Hits = 0;
    player1Misses = 0;
    player2Hits = 0;
    player2Misses = 0;
    player1ShipsDestroyed = 0;
    player2ShipsDestroyed = 0;
    totalShots = 0;
    gameStartTime = null;
    gameEndTime = null;
  }
}
