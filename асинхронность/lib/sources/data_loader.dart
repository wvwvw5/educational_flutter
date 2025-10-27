import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/text_data.dart';

/// Абстрактный класс для загрузки данных
abstract class DataLoader {
  Future<TextData> loadData();
  String get sourceName;
}

/// Загрузчик данных из файла
class FileDataLoader extends DataLoader {
  final String filePath;
  final String encoding;

  FileDataLoader(this.filePath, {this.encoding = 'utf-8'});

  @override
  String get sourceName => 'File: ${filePath.split('/').last}';

  @override
  Future<TextData> loadData() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Файл не найден: $filePath');
      }
      
      final content = await file.readAsString();
      return TextData.fromString(content, sourceName, id: filePath);
    } catch (e) {
      throw Exception('Ошибка загрузки файла $filePath: $e');
    }
  }
}

/// Загрузчик данных из HTTP URL
class HttpDataLoader extends DataLoader {
  final String url;
  final Map<String, String> headers;
  final Duration timeout;

  HttpDataLoader(
    this.url, {
    this.headers = const {},
    this.timeout = const Duration(seconds: 30),
  });

  @override
  String get sourceName => 'HTTP: ${Uri.parse(url).host}';

  @override
  Future<TextData> loadData() async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
      final content = response.body;
      return TextData.fromString(content, sourceName, id: url);
    } catch (e) {
      throw Exception('Ошибка загрузки URL $url: $e');
    }
  }
}

/// Загрузчик данных из строки
class StringDataLoader extends DataLoader {
  final String content;
  final String sourceName;

  StringDataLoader(this.content, this.sourceName);

  @override
  Future<TextData> loadData() async {
    return TextData.fromString(content, sourceName);
  }
}

/// Загрузчик данных из JSON файла
class JsonDataLoader extends DataLoader {
  final String filePath;
  final String contentField;
  final String sourceField;

  JsonDataLoader(
    this.filePath, {
    this.contentField = 'content',
    this.sourceField = 'source',
  });

  @override
  String get sourceName => 'JSON: ${filePath.split('/').last}';

  @override
  Future<TextData> loadData() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('JSON файл не найден: $filePath');
      }
      
      final jsonContent = await file.readAsString();
      final jsonData = jsonDecode(jsonContent) as Map<String, dynamic>;
      
      final content = jsonData[contentField] as String? ?? '';
      final source = jsonData[sourceField] as String? ?? sourceName;
      
      return TextData.fromString(content, source, id: filePath);
    } catch (e) {
      throw Exception('Ошибка загрузки JSON $filePath: $e');
    }
  }
}

/// Менеджер для асинхронной загрузки данных из нескольких источников
class DataLoadManager {
  final List<DataLoader> _loaders = [];
  final Duration _timeout;

  DataLoadManager({Duration? timeout}) : _timeout = timeout ?? const Duration(seconds: 60);

  /// Добавляет загрузчик данных
  void addLoader(DataLoader loader) {
    _loaders.add(loader);
  }

  /// Добавляет загрузчик файла
  void addFileLoader(String filePath, {String encoding = 'utf-8'}) {
    addLoader(FileDataLoader(filePath, encoding: encoding));
  }

  /// Добавляет загрузчик HTTP URL
  void addHttpLoader(String url, {Map<String, String>? headers, Duration? timeout}) {
    addLoader(HttpDataLoader(url, headers: headers ?? {}, timeout: timeout ?? const Duration(seconds: 30)));
  }

  /// Добавляет загрузчик строки
  void addStringLoader(String content, String sourceName) {
    addLoader(StringDataLoader(content, sourceName));
  }

  /// Добавляет загрузчик JSON
  void addJsonLoader(String filePath, {String? contentField, String? sourceField}) {
    addLoader(JsonDataLoader(
      filePath,
      contentField: contentField ?? 'content',
      sourceField: sourceField ?? 'source',
    ));
  }

  /// Загружает данные из всех источников асинхронно
  Future<List<TextData>> loadAllData() async {
    if (_loaders.isEmpty) {
      throw Exception('Нет загрузчиков данных');
    }

    print('🚀 Начинаем загрузку данных из ${_loaders.length} источников...');
    
    final futures = _loaders.map((loader) => _loadWithTimeout(loader));
    final results = await Future.wait(futures, eagerError: false);
    
    // Фильтруем успешные результаты
    final successfulResults = <TextData>[];
    final errors = <String>[];
    
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      if (result is TextData) {
        successfulResults.add(result);
        print('✅ Загружено: ${result.source} (${result.wordCount} слов)');
      } else if (result is Exception) {
        errors.add('${_loaders[i].sourceName}: ${result.toString()}');
        print('❌ Ошибка: ${_loaders[i].sourceName} - ${result.toString()}');
      }
    }
    
    if (errors.isNotEmpty) {
      print('⚠️  Ошибки загрузки: ${errors.length} из ${_loaders.length}');
      for (final error in errors) {
        print('   - $error');
      }
    }
    
    print('📊 Итого загружено: ${successfulResults.length} текстов');
    return successfulResults;
  }

  /// Загружает данные с таймаутом
  Future<dynamic> _loadWithTimeout(DataLoader loader) async {
    try {
      return await loader.loadData().timeout(_timeout);
    } catch (e) {
      return Exception('Таймаут или ошибка загрузки: $e');
    }
  }

  /// Загружает данные последовательно (для отладки)
  Future<List<TextData>> loadDataSequentially() async {
    final results = <TextData>[];
    
    for (final loader in _loaders) {
      try {
        print('🔄 Загружаем: ${loader.sourceName}...');
        final data = await loader.loadData();
        results.add(data);
        print('✅ Загружено: ${data.source} (${data.wordCount} слов)');
      } catch (e) {
        print('❌ Ошибка загрузки ${loader.sourceName}: $e');
      }
    }
    
    return results;
  }

  /// Очищает список загрузчиков
  void clear() {
    _loaders.clear();
  }

  /// Возвращает количество загрузчиков
  int get loaderCount => _loaders.length;
}
