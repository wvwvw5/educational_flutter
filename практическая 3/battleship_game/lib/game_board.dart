import 'dart:math';
import 'ship.dart';

/// Класс для представления игрового поля
class GameBoard {
  final int size;
  final List<List<CellState>> board;
  final List<Ship> ships;
  final Set<Point> missedShots;
  final Set<Point> hitShots;
  final Set<Point> markedCells; // Клетки вокруг потопленных кораблей

  GameBoard(this.size)
      : board = List.generate(
            size, (_) => List.filled(size, CellState.empty)),
        ships = [],
        missedShots = {},
        hitShots = {},
        markedCells = {};

  /// Получить состояние клетки
  CellState getCell(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return CellState.empty;
    }
    return board[row][col];
  }

  /// Установить состояние клетки
  void setCell(int row, int col, CellState state) {
    if (row >= 0 && row < size && col >= 0 && col < size) {
      board[row][col] = state;
    }
  }

  /// Проверяет, можно ли разместить корабль в указанной позиции
  bool canPlaceShip(int row, int col, int length, bool horizontal) {
    // Проверяем границы
    if (horizontal) {
      if (col + length > size) return false;
    } else {
      if (row + length > size) return false;
    }

    // Проверяем, что клетки свободны и вокруг них нет кораблей
    for (int i = 0; i < length; i++) {
      final r = horizontal ? row : row + i;
      final c = horizontal ? col + i : col;

      // Проверяем саму клетку
      if (board[r][c] != CellState.empty) return false;

      // Проверяем соседние клетки (включая диагонали)
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          final nr = r + dr;
          final nc = c + dc;
          if (nr >= 0 &&
              nr < size &&
              nc >= 0 &&
              nc < size &&
              board[nr][nc] == CellState.ship) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Размещает корабль на поле
  bool placeShip(int row, int col, int length, bool horizontal) {
    if (!canPlaceShip(row, col, length, horizontal)) {
      return false;
    }

    final cells = <ShipCell>[];
    for (int i = 0; i < length; i++) {
      final r = horizontal ? row : row + i;
      final c = horizontal ? col + i : col;
      board[r][c] = CellState.ship;
      cells.add(ShipCell(r, c));
    }

    ships.add(Ship(length, cells));
    return true;
  }

  /// Размещает корабль случайным образом
  bool placeShipRandom(int length, Random random) {
    final maxAttempts = 100;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final horizontal = random.nextBool();
      final row = horizontal
          ? random.nextInt(size)
          : random.nextInt(size - length + 1);
      final col = horizontal
          ? random.nextInt(size - length + 1)
          : random.nextInt(size);

      if (placeShip(row, col, length, horizontal)) {
        return true;
      }
    }
    return false;
  }

  /// Обрабатывает выстрел
  ShotResult shoot(int row, int col) {
    // Проверяем границы
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return ShotResult.invalid;
    }

    // Проверяем, не стреляли ли уже сюда
    final point = Point(row, col);
    if (missedShots.contains(point) || hitShots.contains(point)) {
      return ShotResult.alreadyShot;
    }

    // Проверяем попадание
    if (board[row][col] == CellState.ship) {
      hitShots.add(point);
      board[row][col] = CellState.hit;

      // Находим корабль и отмечаем попадание
      for (final ship in ships) {
        for (final cell in ship.cells) {
          if (cell.row == row && cell.col == col) {
            cell.isHit = true;
            final isDestroyed = ship.checkDestroyed();

            if (isDestroyed) {
              // Помечаем клетки вокруг потопленного корабля
              final surrounding = ship.getSurroundingCells(size);
              for (final p in surrounding) {
                markedCells.add(p);
                if (board[p.row][p.col] == CellState.empty) {
                  board[p.row][p.col] = CellState.miss;
                  missedShots.add(p);
                }
              }
              return ShotResult.destroyed;
            }
            return ShotResult.hit;
          }
        }
      }
    } else {
      missedShots.add(point);
      board[row][col] = CellState.miss;
      return ShotResult.miss;
    }

    return ShotResult.miss;
  }

  /// Проверяет, все ли корабли потоплены
  bool allShipsDestroyed() {
    return ships.every((ship) => ship.isDestroyed);
  }

  /// Получает количество оставшихся кораблей
  int getRemainingShips() {
    return ships.where((ship) => !ship.isDestroyed).length;
  }

  /// Получает количество потопленных кораблей
  int getDestroyedShips() {
    return ships.where((ship) => ship.isDestroyed).length;
  }
}

/// Состояния клетки на поле
enum CellState {
  empty, // Пустая клетка
  ship, // Клетка с кораблем (видна только владельцу)
  hit, // Попадание
  miss, // Промах
}

/// Результат выстрела
enum ShotResult {
  hit, // Попадание
  miss, // Промах
  destroyed, // Корабль потоплен
  invalid, // Некорректные координаты
  alreadyShot, // Уже стреляли сюда
}
