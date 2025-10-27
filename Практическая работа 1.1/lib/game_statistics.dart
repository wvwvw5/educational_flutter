import 'dart:io';

class GameStatistics {
  int player1Hits = 0;
  int player1Misses = 0;
  int player2Hits = 0;
  int player2Misses = 0;
  int player1ShipsDestroyed = 0;
  int player2ShipsDestroyed = 0;
  int player1ShipsRemaining = 0;
  int player2ShipsRemaining = 0;
  int totalMoves = 0;
  String winner = '';
  DateTime gameStartTime = DateTime.now();
  DateTime? gameEndTime;
  String gameMode = '';
  int boardSize = 0;

  // Конструктор
  GameStatistics({required this.gameMode, required this.boardSize}) {
    gameStartTime = DateTime.now();
  }

  // Методы для обновления статистики
  void recordPlayer1Hit() {
    player1Hits++;
    totalMoves++;
  }

  void recordPlayer1Miss() {
    player1Misses++;
    totalMoves++;
  }

  void recordPlayer2Hit() {
    player2Hits++;
    totalMoves++;
  }

  void recordPlayer2Miss() {
    player2Misses++;
    totalMoves++;
  }

  void recordPlayer1ShipDestroyed() {
    player1ShipsDestroyed++;
  }

  void recordPlayer2ShipDestroyed() {
    player2ShipsDestroyed++;
  }

  void setPlayer1ShipsRemaining(int ships) {
    player1ShipsRemaining = ships;
  }

  void setPlayer2ShipsRemaining(int ships) {
    player2ShipsRemaining = ships;
  }

  void setWinner(String winnerName) {
    winner = winnerName;
    gameEndTime = DateTime.now();
  }

  // Получение длительности игры
  Duration get gameDuration {
    if (gameEndTime != null) {
      return gameEndTime!.difference(gameStartTime);
    }
    return DateTime.now().difference(gameStartTime);
  }

  // Форматирование статистики для вывода
  String getFormattedStatistics() {
    final duration = gameDuration;
    final durationStr = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    
    return '''
╔══════════════════════════════════════════════════════════════╗
║                    📊 СТАТИСТИКА ИГРЫ 📊                    ║
╠══════════════════════════════════════════════════════════════╣
║ 🎮 Режим игры: $gameMode
║ 📏 Размер поля: ${boardSize}x$boardSize
║ ⏱️  Длительность: $durationStr
║ 🏆 Победитель: $winner
╠══════════════════════════════════════════════════════════════╣
║ 📈 ОБЩАЯ СТАТИСТИКА:
║    🎯 Всего ходов: $totalMoves
║    🎯 Всего попаданий: ${player1Hits + player2Hits}
║    🎯 Всего промахов: ${player1Misses + player2Misses}
╠══════════════════════════════════════════════════════════════╣
║ 👤 ИГРОК 1 (X):
║    ✅ Попадания: $player1Hits
║    ❌ Промахи: $player1Misses
║    🚢 Уничтожено кораблей: $player1ShipsDestroyed
║    🚢 Осталось кораблей: $player1ShipsRemaining
║    📊 Точность: ${player1Hits + player1Misses > 0 ? ((player1Hits / (player1Hits + player1Misses)) * 100).toStringAsFixed(1) : '0.0'}%
╠══════════════════════════════════════════════════════════════╣
║ 👤 ИГРОК 2 (O):
║    ✅ Попадания: $player2Hits
║    ❌ Промахи: $player2Misses
║    🚢 Уничтожено кораблей: $player2ShipsDestroyed
║    🚢 Осталось кораблей: $player2ShipsRemaining
║    📊 Точность: ${player2Hits + player2Misses > 0 ? ((player2Hits / (player2Hits + player2Misses)) * 100).toStringAsFixed(1) : '0.0'}%
╚══════════════════════════════════════════════════════════════╝
''';
  }

  // Сохранение статистики в файл
  Future<void> saveToFile() async {
    try {
      // Создаем каталог для статистики, если его нет
      final statsDir = Directory('game_statistics');
      if (!await statsDir.exists()) {
        await statsDir.create(recursive: true);
      }

      // Создаем имя файла с временной меткой
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'game_stats_$timestamp.txt';
      final file = File('${statsDir.path}/$fileName');

      // Подготавливаем данные для записи
      final fileContent = '''
СТАТИСТИКА ИГРЫ "КРЕСТИКИ-НОЛИКИ"
=====================================

Дата и время: ${DateTime.now().toString()}
Режим игры: $gameMode
Размер поля: ${boardSize}x$boardSize
Длительность игры: ${gameDuration.inMinutes}:${(gameDuration.inSeconds % 60).toString().padLeft(2, '0')}
Победитель: $winner

ОБЩАЯ СТАТИСТИКА:
- Всего ходов: $totalMoves
- Всего попаданий: ${player1Hits + player2Hits}
- Всего промахов: ${player1Misses + player2Misses}

СТАТИСТИКА ИГРОКА 1 (X):
- Попадания: $player1Hits
- Промахи: $player1Misses
- Уничтожено кораблей: $player1ShipsDestroyed
- Осталось кораблей: $player1ShipsRemaining
- Точность: ${player1Hits + player1Misses > 0 ? ((player1Hits / (player1Hits + player1Misses)) * 100).toStringAsFixed(1) : '0.0'}%

СТАТИСТИКА ИГРОКА 2 (O):
- Попадания: $player2Hits
- Промахи: $player2Misses
- Уничтожено кораблей: $player2ShipsDestroyed
- Осталось кораблей: $player2ShipsRemaining
- Точность: ${player2Hits + player2Misses > 0 ? ((player2Hits / (player2Hits + player2Misses)) * 100).toStringAsFixed(1) : '0.0'}%

=====================================
Статистика сохранена: ${DateTime.now().toString()}
''';

      // Записываем в файл
      await file.writeAsString(fileContent);
      print('\n💾 Статистика сохранена в файл: ${file.path}');
      
    } catch (e) {
      print('\n❌ Ошибка при сохранении статистики: $e');
    }
  }
}
