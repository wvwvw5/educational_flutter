import 'dart:io';
import 'dart:math';
import 'game_statistics.dart';

class TicTacToeGame {
  late List<List<String>> board;
  late int boardSize;
  late String currentPlayer;
  late bool isPlayerVsPlayer;
  late bool isPlayerTurn;
  late Random random;
  late GameStatistics gameStats;

  TicTacToeGame() {
    random = Random();
  }

  Future<void> startGame() async {
    print('\n🎯 Добро пожаловать в игру "Крестики-нолики"!');
    
    while (true) {
      print('\n' + '=' * 50);
      print('📋 ГЛАВНОЕ МЕНЮ');
      print('=' * 50);
      print('1. 🆚 Играть против друга');
      print('2. 🤖 Играть против робота');
      print('0. 🚪 Выход');
      print('\nВыберите режим игры (0-2): ');
      
      final choice = stdin.readLineSync()?.trim();
      
      switch (choice) {
        case '1':
          isPlayerVsPlayer = true;
          await setupGame();
          break;
        case '2':
          isPlayerVsPlayer = false;
          await setupGame();
          break;
        case '0':
          print('\n👋 Спасибо за игру! До свидания!');
          exit(0);
        default:
          print('\n❌ Неверный выбор. Попробуйте снова.');
      }
    }
  }

  Future<void> setupGame() async {
    // Запрос размера поля
    while (true) {
      print('\n📏 Введите размер игрового поля (3-10): ');
      final sizeInput = stdin.readLineSync()?.trim();
      
      if (sizeInput != null) {
        final size = int.tryParse(sizeInput);
        if (size != null && size >= 3 && size <= 10) {
          boardSize = size;
          break;
        }
      }
      print('❌ Пожалуйста, введите число от 3 до 10.');
    }

    // Инициализация поля
    board = List.generate(
      boardSize, 
      (i) => List.generate(boardSize, (j) => ' ')
    );

    // Инициализация статистики
    final gameMode = isPlayerVsPlayer ? 'Игрок против игрока' : 'Игрок против робота';
    gameStats = GameStatistics(gameMode: gameMode, boardSize: boardSize);
    
    // Устанавливаем начальное количество "кораблей" (клеток для заполнения)
    gameStats.setPlayer1ShipsRemaining(boardSize * boardSize);
    gameStats.setPlayer2ShipsRemaining(boardSize * boardSize);

    // Случайный выбор первого игрока
    currentPlayer = random.nextBool() ? 'X' : 'O';
    isPlayerTurn = true;

    print('\n🎲 Первым ходит игрок: $currentPlayer');
    print('🎮 Начинаем игру!');
    
    await playGame();
  }

  Future<void> playGame() async {
    while (true) {
      displayBoard();
      
      if (checkWinner() != null) {
        await displayWinner();
        break;
      }
      
      if (isBoardFull()) {
        await displayDraw();
        break;
      }

      if (isPlayerVsPlayer || isPlayerTurn) {
        // Ход игрока
        makePlayerMove();
      } else {
        // Ход робота
        makeRobotMove();
      }
      
      // Переключение игрока
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      isPlayerTurn = !isPlayerTurn;
    }
    
    await askForNewGame();
  }

  void displayBoard() {
    print('\n' + '=' * (boardSize * 4 + 1));
    print('🎯 ИГРОВОЕ ПОЛЕ');
    print('=' * (boardSize * 4 + 1));
    
    // Нумерация столбцов
    print('   ' + List.generate(boardSize, (i) => '${(i + 1).toString().padLeft(2)}').join(' '));
    
    for (int i = 0; i < boardSize; i++) {
      String row = '${(i + 1).toString().padLeft(2)} ';
      for (int j = 0; j < boardSize; j++) {
        String cell = board[i][j];
        if (cell == ' ') {
          cell = '·';
        }
        row += '|$cell ';
      }
      row += '|';
      print(row);
      
      if (i < boardSize - 1) {
        print('   ' + '---' * boardSize + '-');
      }
    }
    print('=' * (boardSize * 4 + 1));
  }

  void makePlayerMove() {
    while (true) {
      print('\n🎯 Ход игрока $currentPlayer');
      print('Введите координаты (строка столбец, например: 1 2): ');
      
      final input = stdin.readLineSync()?.trim();
      if (input == null || input.isEmpty) {
        print('❌ Пожалуйста, введите координаты.');
        continue;
      }
      
      final coords = input.split(' ');
      if (coords.length != 2) {
        print('❌ Введите два числа через пробел.');
        continue;
      }
      
      final row = int.tryParse(coords[0]);
      final col = int.tryParse(coords[1]);
      
      if (row == null || col == null) {
        print('❌ Пожалуйста, введите числа.');
        continue;
      }
      
      if (row < 1 || row > boardSize || col < 1 || col > boardSize) {
        print('❌ Координаты должны быть от 1 до $boardSize.');
        continue;
      }
      
      if (board[row - 1][col - 1] != ' ') {
        print('❌ Эта клетка уже занята!');
        continue;
      }
      
      board[row - 1][col - 1] = currentPlayer;
      
      // Обновляем статистику
      if (currentPlayer == 'X') {
        gameStats.recordPlayer1Hit();
        gameStats.setPlayer1ShipsRemaining(gameStats.player1ShipsRemaining - 1);
      } else {
        gameStats.recordPlayer2Hit();
        gameStats.setPlayer2ShipsRemaining(gameStats.player2ShipsRemaining - 1);
      }
      
      break;
    }
  }

  void makeRobotMove() {
    print('\n🤖 Ход робота...');
    
    // Простая стратегия: сначала попытаться выиграть, потом блокировать игрока
    var move = findWinningMove('O') ?? findWinningMove('X') ?? findRandomMove();
    
    if (move != null) {
      board[move[0]][move[1]] = currentPlayer;
      print('🤖 Робот поставил $currentPlayer в позицию (${move[0] + 1}, ${move[1] + 1})');
      
      // Обновляем статистику для робота
      if (currentPlayer == 'O') {
        gameStats.recordPlayer2Hit();
        gameStats.setPlayer2ShipsRemaining(gameStats.player2ShipsRemaining - 1);
      }
    }
  }

  List<int>? findWinningMove(String player) {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == ' ') {
          board[i][j] = player;
          if (checkWinner() == player) {
            board[i][j] = ' ';
            return [i, j];
          }
          board[i][j] = ' ';
        }
      }
    }
    return null;
  }

  List<int>? findRandomMove() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == ' ') {
          emptyCells.add([i, j]);
        }
      }
    }
    
    if (emptyCells.isEmpty) return null;
    return emptyCells[random.nextInt(emptyCells.length)];
  }

  String? checkWinner() {
    // Проверка строк
    for (int i = 0; i < boardSize; i++) {
      if (board[i][0] != ' ' && 
          board[i].every((cell) => cell == board[i][0])) {
        return board[i][0];
      }
    }
    
    // Проверка столбцов
    for (int j = 0; j < boardSize; j++) {
      if (board[0][j] != ' ' && 
          List.generate(boardSize, (i) => board[i][j]).every((cell) => cell == board[0][j])) {
        return board[0][j];
      }
    }
    
    // Проверка главной диагонали
    if (board[0][0] != ' ' && 
        List.generate(boardSize, (i) => board[i][i]).every((cell) => cell == board[0][0])) {
      return board[0][0];
    }
    
    // Проверка побочной диагонали
    if (board[0][boardSize - 1] != ' ' && 
        List.generate(boardSize, (i) => board[i][boardSize - 1 - i]).every((cell) => cell == board[0][boardSize - 1])) {
      return board[0][boardSize - 1];
    }
    
    return null;
  }

  bool isBoardFull() {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == ' ') {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> displayWinner() async {
    displayBoard();
    final winner = checkWinner();
    
    // Устанавливаем победителя в статистику
    gameStats.setWinner(winner!);
    
    print('\n🎉 ПОЗДРАВЛЯЕМ!');
    print('🏆 Победитель: $winner');
    
    if (isPlayerVsPlayer) {
      print('👥 Отличная игра!');
    } else if (winner == 'O') {
      print('🤖 Робот победил! Попробуйте еще раз!');
    } else {
      print('🎯 Вы победили робота! Отлично!');
    }
    
    // Отображаем и сохраняем статистику
    await displayAndSaveStatistics();
  }

  Future<void> displayDraw() async {
    displayBoard();
    
    // Устанавливаем ничью в статистику
    gameStats.setWinner('Ничья');
    
    print('\n🤝 НИЧЬЯ!');
    print('🎯 Отличная игра! Никто не проиграл!');
    
    // Отображаем и сохраняем статистику
    await displayAndSaveStatistics();
  }

  Future<void> askForNewGame() async {
    print('\n' + '-' * 50);
    print('🔄 Хотите сыграть еще раз?');
    print('1. ✅ Да, новая игра');
    print('2. 🏠 Вернуться в главное меню');
    print('0. 🚪 Выход');
    print('\nВыберите действие (0-2): ');
    
    final choice = stdin.readLineSync()?.trim();
    
    switch (choice) {
        case '1':
          await setupGame();
          break;
        case '2':
          await startGame();
          break;
      case '0':
        print('\n👋 Спасибо за игру! До свидания!');
        exit(0);
      default:
        print('\n❌ Неверный выбор. Возвращаемся в главное меню...');
        await startGame();
    }
  }

  // Метод для отображения и сохранения статистики
  Future<void> displayAndSaveStatistics() async {
    print('\n' + '=' * 60);
    print(gameStats.getFormattedStatistics());
    
    // Сохраняем статистику в файл
    await gameStats.saveToFile();
  }
}
