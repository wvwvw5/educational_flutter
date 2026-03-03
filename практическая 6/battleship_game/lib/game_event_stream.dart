import 'dart:async';
import 'dart:io';
import 'game_board.dart';

/// Базовый класс для всех игровых событий
abstract class GameEvent {
  final DateTime timestamp;
  final String description;

  GameEvent(this.description) : timestamp = DateTime.now();

  @override
  String toString() =>
      '[${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}] $description';
}

/// Событие выстрела
class ShotEvent extends GameEvent {
  final int player;
  final int row;
  final int col;
  final ShotResult result;

  ShotEvent(this.player, this.row, this.col, this.result)
      : super(
            'Игрок $player стреляет (${String.fromCharCode(65 + row)}${col + 1}): ${_resultToString(result)}');

  static String _resultToString(ShotResult result) {
    switch (result) {
      case ShotResult.hit:
        return 'Попадание';
      case ShotResult.miss:
        return 'Промах';
      case ShotResult.destroyed:
        return 'Корабль потоплен';
      case ShotResult.invalid:
        return 'Некорректный выстрел';
      case ShotResult.alreadyShot:
        return 'Повторный выстрел';
    }
  }
}

/// Событие уничтожения корабля
class ShipDestroyedEvent extends GameEvent {
  final int owner;
  final int shipLength;

  ShipDestroyedEvent(this.owner, this.shipLength)
      : super(
            'Корабль игрока $owner (размер $shipLength) потоплен!');
}

/// Событие смены хода
class TurnChangeEvent extends GameEvent {
  final int nextPlayer;

  TurnChangeEvent(this.nextPlayer)
      : super('Ход переходит к игроку $nextPlayer');
}

/// Событие завершения игры
class GameOverEvent extends GameEvent {
  final int winner;
  final int totalShots;

  GameOverEvent(this.winner, this.totalShots)
      : super('Игра окончена! Победитель: Игрок $winner (всего выстрелов: $totalShots)');
}

/// Событие размещения кораблей
class ShipPlacedEvent extends GameEvent {
  final int player;
  final int shipLength;

  ShipPlacedEvent(this.player, this.shipLength)
      : super('Игрок $player: размещён корабль (размер $shipLength)');
}

/// Событие начала анализа поля в Isolate
class AnalysisEvent extends GameEvent {
  final String analysisResult;

  AnalysisEvent(this.analysisResult)
      : super('Анализ поля: $analysisResult');
}

/// Менеджер потока игровых событий
///
/// Использует StreamController для трансляции событий в реальном времени.
/// Поддерживает broadcast-подписку (несколько слушателей одновременно)
/// и автоматическое логирование в файл.
class GameEventStream {
  /// Broadcast StreamController — позволяет нескольким подписчикам
  final StreamController<GameEvent> _controller =
      StreamController<GameEvent>.broadcast();

  /// Список всех событий для финального отчёта
  final List<GameEvent> _eventLog = [];

  /// Подписка на логирование в файл
  StreamSubscription<GameEvent>? _fileLogSubscription;

  /// Файл для логирования
  IOSink? _logSink;

  /// Получить Stream для подписки
  Stream<GameEvent> get stream => _controller.stream;

  /// Получить список всех событий
  List<GameEvent> get eventLog => List.unmodifiable(_eventLog);

  /// Количество событий
  int get eventCount => _eventLog.length;

  /// Добавить событие в поток
  void addEvent(GameEvent event) {
    _eventLog.add(event);
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Запустить логирование событий в файл (async запись через Stream)
  Future<void> startFileLogging(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$directoryPath/game_log_$timestamp.txt';
    final file = File(filePath);
    _logSink = file.openWrite();

    _logSink!.writeln('╔═══════════════════════════════════════════════════════════╗');
    _logSink!.writeln('║            📋 ЛОГ ИГРЫ "МОРСКОЙ БОЙ" 📋                 ║');
    _logSink!.writeln('╚═══════════════════════════════════════════════════════════╝');
    _logSink!.writeln('Начало записи: ${DateTime.now()}\n');

    // Подписка на Stream для записи каждого события в файл
    _fileLogSubscription = _controller.stream.listen(
      (event) {
        _logSink?.writeln(event.toString());
      },
      onError: (error) {
        _logSink?.writeln('[ERROR] $error');
      },
    );

    print('📋 Логирование событий запущено: $filePath');
  }

  /// Остановить логирование и закрыть файл
  Future<void> stopFileLogging() async {
    await _fileLogSubscription?.cancel();
    _fileLogSubscription = null;

    if (_logSink != null) {
      _logSink!.writeln('\nЗапись завершена: ${DateTime.now()}');
      _logSink!.writeln('Всего событий: ${_eventLog.length}');
      await _logSink!.flush();
      await _logSink!.close();
      _logSink = null;
    }
  }

  /// Получить Stream событий определённого типа (фильтрация потока)
  Stream<T> whereType<T extends GameEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Получить Stream только выстрелов
  Stream<ShotEvent> get shotEvents => whereType<ShotEvent>();

  /// Получить Stream только уничтожений
  Stream<ShipDestroyedEvent> get destroyedEvents =>
      whereType<ShipDestroyedEvent>();

  /// Преобразовать поток событий в поток строк (Stream.map)
  Stream<String> get eventDescriptions =>
      _controller.stream.map((event) => event.toString());

  /// Закрыть поток
  Future<void> dispose() async {
    await stopFileLogging();
    await _controller.close();
  }
}
