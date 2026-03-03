import 'dart:isolate';
import 'dart:math';

/// Данные, передаваемые в Isolate для расчёта хода ИИ.
/// Isolate не может работать с объектами из основного потока,
/// поэтому мы передаём только примитивные данные (сериализуемые).
class AiComputeData {
  final int boardSize;
  final List<List<int>> boardState; // 0=empty, 1=ship, 2=hit, 3=miss
  final List<List<int>> hitPositions; // Позиции попаданий [[row, col], ...]
  final List<List<int>> missPositions; // Позиции промахов
  final int? lastHitRow;
  final int? lastHitCol;

  AiComputeData({
    required this.boardSize,
    required this.boardState,
    required this.hitPositions,
    required this.missPositions,
    this.lastHitRow,
    this.lastHitCol,
  });
}

/// Результат вычислений ИИ из Isolate
class AiComputeResult {
  final int row;
  final int col;
  final double confidence; // Уверенность в выстреле (0.0 - 1.0)
  final String reasoning; // Объяснение выбора

  AiComputeResult({
    required this.row,
    required this.col,
    required this.confidence,
    required this.reasoning,
  });
}

/// Вычисляет лучший ход ИИ в отдельном Isolate.
///
/// Использует Isolate.run() для выполнения тяжёлых вычислений
/// без блокировки основного потока. Функция _computeBestMove
/// является top-level функцией (обязательное требование для Isolate).
Future<AiComputeResult> computeAiMoveInIsolate(AiComputeData data) async {
  // Isolate.run() создаёт новый изолят, выполняет функцию и возвращает результат
  final result = await Isolate.run(() => _computeBestMove(data));
  return result;
}

/// Top-level функция для выполнения в Isolate.
/// Не может обращаться к глобальному состоянию основного потока.
AiComputeResult _computeBestMove(AiComputeData data) {
  final random = Random();
  final size = data.boardSize;

  // Строим карту доступных выстрелов
  final available = <List<int>>[];
  for (int r = 0; r < size; r++) {
    for (int c = 0; c < size; c++) {
      if (data.boardState[r][c] != 2 && data.boardState[r][c] != 3) {
        available.add([r, c]);
      }
    }
  }

  if (available.isEmpty) {
    return AiComputeResult(
      row: 0,
      col: 0,
      confidence: 0.0,
      reasoning: 'Нет доступных клеток',
    );
  }

  // Стратегия 1: Если есть попадания, ищем продолжение корабля
  if (data.lastHitRow != null && data.lastHitCol != null) {
    final directions = [
      [-1, 0], // вверх
      [1, 0], // вниз
      [0, -1], // влево
      [0, 1], // вправо
    ];

    for (final dir in directions) {
      final nr = data.lastHitRow! + dir[0];
      final nc = data.lastHitCol! + dir[1];
      if (nr >= 0 &&
          nr < size &&
          nc >= 0 &&
          nc < size &&
          data.boardState[nr][nc] != 2 &&
          data.boardState[nr][nc] != 3) {
        return AiComputeResult(
          row: nr,
          col: nc,
          confidence: 0.85,
          reasoning: 'Продолжение поиска корабля рядом с попаданием',
        );
      }
    }
  }

  // Стратегия 2: Вычисляем "тепловую карту" вероятностей
  // Клетки рядом с попаданиями имеют более высокий приоритет
  final heatMap = List.generate(size, (_) => List.filled(size, 0.0));

  for (final hit in data.hitPositions) {
    final hr = hit[0];
    final hc = hit[1];
    // Увеличиваем приоритет соседних клеток
    for (final dir in [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
      final nr = hr + dir[0];
      final nc = hc + dir[1];
      if (nr >= 0 &&
          nr < size &&
          nc >= 0 &&
          nc < size &&
          data.boardState[nr][nc] != 2 &&
          data.boardState[nr][nc] != 3) {
        heatMap[nr][nc] += 3.0;
      }
    }
  }

  // Стратегия 3: Шахматный паттерн (более эффективное покрытие)
  for (final pos in available) {
    if ((pos[0] + pos[1]) % 2 == 0) {
      heatMap[pos[0]][pos[1]] += 1.0;
    }
  }

  // Находим клетку с максимальным приоритетом
  double maxHeat = -1;
  var bestShots = <List<int>>[];

  for (final pos in available) {
    final heat = heatMap[pos[0]][pos[1]];
    if (heat > maxHeat) {
      maxHeat = heat;
      bestShots = [pos];
    } else if (heat == maxHeat) {
      bestShots.add(pos);
    }
  }

  // Выбираем случайный из лучших вариантов
  final chosen = bestShots[random.nextInt(bestShots.length)];
  final confidence = maxHeat > 2.0 ? 0.75 : (maxHeat > 0 ? 0.5 : 0.25);
  final reasoning = maxHeat > 2.0
      ? 'Целенаправленный выстрел рядом с попаданием'
      : (maxHeat > 0
          ? 'Стратегический выстрел по шахматному паттерну'
          : 'Случайный выстрел');

  return AiComputeResult(
    row: chosen[0],
    col: chosen[1],
    confidence: confidence,
    reasoning: reasoning,
  );
}
