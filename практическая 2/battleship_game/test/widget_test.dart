// Тесты для игры Морской бой
import 'package:flutter_test/flutter_test.dart';
import 'package:battleship_game/game_board.dart';
import 'package:battleship_game/ship.dart';

void main() {
  test('GameBoard создается корректно', () {
    final board = GameBoard(10);
    expect(board.size, 10);
    expect(board.ships.length, 0);
  });

  test('Можно разместить корабль', () {
    final board = GameBoard(10);
    final result = board.placeShip(0, 0, 3, true);
    expect(result, true);
    expect(board.ships.length, 1);
  });

  test('Выстрел работает корректно', () {
    final board = GameBoard(10);
    board.placeShip(0, 0, 2, true);
    
    final result1 = board.shoot(0, 0);
    expect(result1, ShotResult.hit);
    
    final result2 = board.shoot(0, 1);
    expect(result2, ShotResult.destroyed);
    
    final result3 = board.shoot(5, 5);
    expect(result3, ShotResult.miss);
  });
}