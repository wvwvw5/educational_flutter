import 'game_logic.dart';

void main() async {
  print('=' * 60);
  print('🎮 ИГРА "КРЕСТИКИ-НОЛИКИ" 🎮');
  print('=' * 60);
  
  final game = TicTacToeGame();
  await game.startGame();
}
