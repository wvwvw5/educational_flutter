import 'dart:io';
import 'game_board.dart';

/// Класс для хранения статистики игры
class GameStatistics {
  int player1Hits = 0;
  int player1Misses = 0;
  int player2Hits = 0;
  int player2Misses = 0;
  int player1ShipsDestroyed = 0; // Количество разрушенных кораблей противника игроком 1
  int player2ShipsDestroyed = 0; // Количество разрушенных кораблей противника игроком 2
  int player1ShipsLost = 0; // Количество потерянных кораблей игроком 1
  int player2ShipsLost = 0; // Количество потерянных кораблей игроком 2
  int totalShots = 0;
  int totalShipsPlayer1 = 0; // Общее количество кораблей игрока 1
  int totalShipsPlayer2 = 0; // Общее количество кораблей игрока 2
  DateTime? gameStartTime;
  DateTime? gameEndTime;
  String? gameMode; // Режим игры
  int? boardSize; // Размер поля

  /// Начинает отсчет времени игры
  void startGame() {
    gameStartTime = DateTime.now();
  }

  /// Заканчивает игру
  void endGame() {
    gameEndTime = DateTime.now();
  }

  /// Устанавливает общее количество кораблей
  void setTotalShips(int player, int total) {
    if (player == 1) {
      totalShipsPlayer1 = total;
    } else {
      totalShipsPlayer2 = total;
    }
  }

  /// Обновляет количество потерянных кораблей
  void updateShipsLost(int player, int lost) {
    if (player == 1) {
      player1ShipsLost = lost;
    } else {
      player2ShipsLost = lost;
    }
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

  /// Получает количество оставшихся кораблей игрока 1
  int getPlayer1RemainingShips() {
    return totalShipsPlayer1 - player1ShipsLost;
  }

  /// Получает количество оставшихся кораблей игрока 2
  int getPlayer2RemainingShips() {
    return totalShipsPlayer2 - player2ShipsLost;
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
    player1ShipsLost = 0;
    player2ShipsLost = 0;
    totalShots = 0;
    totalShipsPlayer1 = 0;
    totalShipsPlayer2 = 0;
    gameStartTime = null;
    gameEndTime = null;
    gameMode = null;
    boardSize = null;
  }

  /// Сохраняет статистику в файл
  Future<void> saveToFile(String directoryPath) async {
    try {
      // Создаем каталог, если его нет
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Создаем имя файла с временной меткой
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'game_statistics_$timestamp.txt';
      final filePath = '$directoryPath/$fileName';

      // Создаем файл и записываем статистику
      final file = File(filePath);
      final content = _generateStatisticsReport();
      await file.writeAsString(content);

      print('✅ Статистика сохранена в файл: $filePath');
    } catch (e) {
      print('❌ Ошибка при сохранении статистики: $e');
    }
  }

  /// Генерирует отчет о статистике
  String _generateStatisticsReport() {
    final buffer = StringBuffer();
    final duration = getGameDuration();

    buffer.writeln('╔═══════════════════════════════════════════════════════════╗');
    buffer.writeln('║          📊 СТАТИСТИКА ИГРЫ "МОРСКОЙ БОЙ" 📊            ║');
    buffer.writeln('╚═══════════════════════════════════════════════════════════╝');
    buffer.writeln('');
    buffer.writeln('📅 Дата игры: ${gameStartTime?.toString() ?? "Неизвестно"}');
    buffer.writeln('🎮 Режим игры: ${gameMode ?? "Неизвестно"}');
    if (boardSize != null) {
      buffer.writeln('📏 Размер поля: ${boardSize}x$boardSize');
    }
    if (duration != null) {
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      buffer.writeln('⏱️  Длительность игры: ${minutes}м ${seconds}с');
    }
    buffer.writeln('');
    buffer.writeln('${'=' * 60}');
    buffer.writeln('👤 ИГРОК 1:');
    buffer.writeln('${'=' * 60}');
    buffer.writeln('🎯 Разрушено кораблей противника: $player1ShipsDestroyed');
    buffer.writeln('💔 Потеряно кораблей: $player1ShipsLost');
    buffer.writeln('🚢 Осталось кораблей на поле: ${getPlayer1RemainingShips()}/$totalShipsPlayer1');
    buffer.writeln('✅ Попаданий: $player1Hits');
    buffer.writeln('❌ Промахов: $player1Misses');
    buffer.writeln('📊 Точность: ${getPlayer1Accuracy().toStringAsFixed(1)}%');
    buffer.writeln('');
    buffer.writeln('${'=' * 60}');
    buffer.writeln('${gameMode == "Игра против ИИ" ? "🤖 КОМПЬЮТЕР" : "👤 ИГРОК 2"}:');
    buffer.writeln('${'=' * 60}');
    buffer.writeln('🎯 Разрушено кораблей противника: $player2ShipsDestroyed');
    buffer.writeln('💔 Потеряно кораблей: $player2ShipsLost');
    buffer.writeln('🚢 Осталось кораблей на поле: ${getPlayer2RemainingShips()}/$totalShipsPlayer2');
    buffer.writeln('✅ Попаданий: $player2Hits');
    buffer.writeln('❌ Промахов: $player2Misses');
    buffer.writeln('📊 Точность: ${getPlayer2Accuracy().toStringAsFixed(1)}%');
    buffer.writeln('');
    buffer.writeln('${'=' * 60}');
    buffer.writeln('📈 ОБЩАЯ СТАТИСТИКА:');
    buffer.writeln('${'=' * 60}');
    buffer.writeln('🎯 Всего выстрелов: $totalShots');
    buffer.writeln('✅ Всего попаданий: ${player1Hits + player2Hits}');
    buffer.writeln('❌ Всего промахов: ${player1Misses + player2Misses}');
    buffer.writeln('💥 Всего потоплено кораблей: ${player1ShipsDestroyed + player2ShipsDestroyed}');
    buffer.writeln('');

    return buffer.toString();
  }
}