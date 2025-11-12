import 'dart:math';
import 'game_board.dart';
import 'ship.dart';

/// Класс для ИИ компьютера
class AI {
  final Random random;
  final GameBoard enemyBoard;
  final List<Point> availableShots;
  final List<Point> hitCells; // Клетки с попаданиями
  Point? lastHit; // Последнее попадание для поиска направления

  AI(this.enemyBoard, Random? seed)
      : random = seed ?? Random(),
        availableShots = [],
        hitCells = [] {
    // Инициализируем список доступных выстрелов
    for (int row = 0; row < enemyBoard.size; row++) {
      for (int col = 0; col < enemyBoard.size; col++) {
        availableShots.add(Point(row, col));
      }
    }
    availableShots.shuffle(random);
  }

  /// Делает ход ИИ
  Point makeMove() {
    // Если есть попадания, пытаемся найти корабль
    if (hitCells.isNotEmpty && lastHit != null) {
      final nextShot = findNextShot();
      if (nextShot != null) {
        availableShots.remove(nextShot);
        return nextShot;
      }
    }

    // Иначе делаем случайный выстрел
    if (availableShots.isEmpty) {
      // Если список пуст, пересоздаем его
      for (int row = 0; row < enemyBoard.size; row++) {
        for (int col = 0; col < enemyBoard.size; col++) {
          final point = Point(row, col);
          if (!enemyBoard.hitShots.contains(point) &&
              !enemyBoard.missedShots.contains(point)) {
            availableShots.add(point);
          }
        }
      }
      availableShots.shuffle(random);
    }

    if (availableShots.isEmpty) {
      // Если все равно пусто, возвращаем случайную точку
      return Point(
          random.nextInt(enemyBoard.size), random.nextInt(enemyBoard.size));
    }

    final shot = availableShots.removeAt(0);
    return shot;
  }

  /// Ищет следующий выстрел на основе попаданий
  Point? findNextShot() {
    if (lastHit == null) return null;

    final directions = [
      Point(-1, 0), // Вверх
      Point(1, 0), // Вниз
      Point(0, -1), // Влево
      Point(0, 1), // Вправо
    ];

    // Пробуем найти направление корабля
    for (final dir in directions) {
      final next = Point(lastHit!.row + dir.row, lastHit!.col + dir.col);
      if (isValidShot(next) && availableShots.contains(next)) {
        return next;
      }
    }

    // Если не нашли направление, ищем любую соседнюю клетку
    for (final dir in directions) {
      final next = Point(lastHit!.row + dir.row, lastHit!.col + dir.col);
      if (isValidShot(next) && availableShots.contains(next)) {
        return next;
      }
    }

    return null;
  }

  /// Проверяет, валиден ли выстрел
  bool isValidShot(Point point) {
    return point.row >= 0 &&
        point.row < enemyBoard.size &&
        point.col >= 0 &&
        point.col < enemyBoard.size &&
        !enemyBoard.hitShots.contains(point) &&
        !enemyBoard.missedShots.contains(point);
  }

  /// Обновляет состояние ИИ после выстрела
  void updateAfterShot(Point shot, ShotResult result) {
    if (result == ShotResult.hit || result == ShotResult.destroyed) {
      hitCells.add(shot);
      lastHit = shot;

      if (result == ShotResult.destroyed) {
        // Корабль потоплен, очищаем информацию о поиске
        lastHit = null;
        // Удаляем соседние клетки из доступных (они уже помечены)
        final surrounding = _getSurroundingCells(shot);
        for (final cell in surrounding) {
          availableShots.remove(cell);
        }
      }
    } else {
      // Промах - убираем из доступных
      availableShots.remove(shot);
    }
  }

  /// Получает соседние клетки
  List<Point> _getSurroundingCells(Point point) {
    final cells = <Point>[];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final newRow = point.row + dr;
        final newCol = point.col + dc;
        if (newRow >= 0 &&
            newRow < enemyBoard.size &&
            newCol >= 0 &&
            newCol < enemyBoard.size) {
          cells.add(Point(newRow, newCol));
        }
      }
    }
    return cells;
  }
}
