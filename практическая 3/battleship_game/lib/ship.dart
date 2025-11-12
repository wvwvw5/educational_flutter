/// Класс для представления корабля
class Ship {
  final int length;
  final List<ShipCell> cells;
  bool isDestroyed;

  Ship(this.length, this.cells) : isDestroyed = false;

  /// Проверяет, потоплен ли корабль
  bool checkDestroyed() {
    isDestroyed = cells.every((cell) => cell.isHit);
    return isDestroyed;
  }

  /// Получает все клетки вокруг корабля для пометки
  List<Point> getSurroundingCells(int boardSize) {
    final surrounding = <Point>{};
    for (final cell in cells) {
      final row = cell.row;
      final col = cell.col;
      // Проверяем все 8 соседних клеток
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final newRow = row + dr;
          final newCol = col + dc;
          if (newRow >= 0 &&
              newRow < boardSize &&
              newCol >= 0 &&
              newCol < boardSize) {
            surrounding.add(Point(newRow, newCol));
          }
        }
      }
    }
    // Убираем клетки самого корабля
    for (final cell in cells) {
      surrounding.remove(Point(cell.row, cell.col));
    }
    return surrounding.toList();
  }
}

/// Класс для представления клетки корабля
class ShipCell {
  final int row;
  final int col;
  bool isHit;

  ShipCell(this.row, this.col) : isHit = false;
}

/// Класс для представления точки на поле
class Point {
  final int row;
  final int col;

  Point(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}
