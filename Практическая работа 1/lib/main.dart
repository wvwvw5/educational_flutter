import 'game_logic.dart';

void main() {
  print('=' * 60);
  print('🎮 ИГРА "КРЕСТИКИ-НОЛИКИ" 🎮');
  print('=' * 60);
  
  final game = TicTacToeGame();
  game.startGame();
}
