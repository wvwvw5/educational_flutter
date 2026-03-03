import 'dart:isolate';

/// Данные поля для анализа в Isolate
class BoardAnalysisData {
  final int boardSize;
  final List<List<int>> boardState; // 0=empty, 1=ship, 2=hit, 3=miss
  final int totalShips;
  final int destroyedShips;
  final int hits;
  final int misses;

  BoardAnalysisData({
    required this.boardSize,
    required this.boardState,
    required this.totalShips,
    required this.destroyedShips,
    required this.hits,
    required this.misses,
  });
}

/// Результат анализа поля
class BoardAnalysisResult {
  final double coveragePercent; // Процент исследованных клеток
  final double hitRate; // Процент попаданий
  final int unexploredCells; // Количество неисследованных клеток
  final List<List<double>> dangerMap; // Карта опасных зон
  final String recommendation; // Рекомендация для игрока
  final int estimatedShipsRemaining; // Оценка оставшихся кораблей
  final double gameProgress; // Прогресс игры (0.0 - 1.0)

  BoardAnalysisResult({
    required this.coveragePercent,
    required this.hitRate,
    required this.unexploredCells,
    required this.dangerMap,
    required this.recommendation,
    required this.estimatedShipsRemaining,
    required this.gameProgress,
  });
}

/// Анализирует игровое поле в отдельном Isolate.
///
/// Выполняет тяжёлые вычисления: построение карты опасных зон,
/// расчёт статистики покрытия, прогноз оставшихся кораблей.
/// Isolate.run() обеспечивает неблокирующее выполнение.
Future<BoardAnalysisResult> analyzeBoardInIsolate(
    BoardAnalysisData data) async {
  final result = await Isolate.run(() => _performAnalysis(data));
  return result;
}

/// Top-level функция анализа поля (выполняется в Isolate)
BoardAnalysisResult _performAnalysis(BoardAnalysisData data) {
  final size = data.boardSize;
  final totalCells = size * size;

  // Подсчёт исследованных и неисследованных клеток
  int exploredCells = 0;
  int unexploredCells = 0;

  for (int r = 0; r < size; r++) {
    for (int c = 0; c < size; c++) {
      if (data.boardState[r][c] == 2 || data.boardState[r][c] == 3) {
        exploredCells++;
      } else {
        unexploredCells++;
      }
    }
  }

  final coveragePercent =
      totalCells > 0 ? (exploredCells / totalCells) * 100 : 0.0;
  final totalShots = data.hits + data.misses;
  final hitRate = totalShots > 0 ? (data.hits / totalShots) * 100 : 0.0;

  // Построение карты опасных зон (вероятность нахождения корабля)
  final dangerMap = List.generate(size, (_) => List.filled(size, 0.0));

  for (int r = 0; r < size; r++) {
    for (int c = 0; c < size; c++) {
      if (data.boardState[r][c] == 2 || data.boardState[r][c] == 3) {
        dangerMap[r][c] = 0.0; // Уже исследовано
        continue;
      }

      double danger = 1.0;

      // Повышаем опасность рядом с попаданиями
      for (final dir in [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
        final nr = r + dir[0];
        final nc = c + dir[1];
        if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
          if (data.boardState[nr][nc] == 2) {
            danger += 3.0; // Рядом с попаданием — высокая опасность
          }
          if (data.boardState[nr][nc] == 3) {
            danger -= 0.3; // Рядом с промахом — чуть безопаснее
          }
        }
      }

      // Снижаем опасность в углах (корабли реже там)
      if ((r == 0 || r == size - 1) && (c == 0 || c == size - 1)) {
        danger *= 0.7;
      }

      dangerMap[r][c] = danger.clamp(0.0, 10.0);
    }
  }

  // Оценка оставшихся кораблей
  final estimatedRemaining = data.totalShips - data.destroyedShips;

  // Прогресс игры
  final gameProgress = data.totalShips > 0
      ? data.destroyedShips / data.totalShips
      : 0.0;

  // Генерация рекомендации
  String recommendation;
  if (hitRate > 50) {
    recommendation = 'Отличная точность! Продолжайте в том же духе.';
  } else if (hitRate > 30) {
    recommendation = 'Хорошая точность. Попробуйте стрелять рядом с попаданиями.';
  } else if (coveragePercent > 50) {
    recommendation = 'Исследовано больше половины поля. Сосредоточьтесь на кластерах.';
  } else {
    recommendation =
        'Используйте шахматный паттерн для более эффективного поиска.';
  }

  return BoardAnalysisResult(
    coveragePercent: coveragePercent,
    hitRate: hitRate,
    unexploredCells: unexploredCells,
    dangerMap: dangerMap,
    recommendation: recommendation,
    estimatedShipsRemaining: estimatedRemaining,
    gameProgress: gameProgress,
  );
}
