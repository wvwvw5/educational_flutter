import 'dart:io';
import 'sources/data_loader.dart';
import 'analysis/text_analyzer.dart';
import 'reports/report_generator.dart';
import 'models/text_data.dart';
import 'models/analysis_result.dart';
import 'models/summary_report.dart';

/// Основной класс системы анализа текстов
class TextAnalysisSystem {
  final DataLoadManager _loadManager;
  final TextAnalyzer _analyzer;
  final ReportGenerator _reportGenerator;

  TextAnalysisSystem({
    Duration? loadTimeout,
    Set<String>? stopWords,
    String? outputDirectory,
  }) : _loadManager = DataLoadManager(timeout: loadTimeout),
       _analyzer = TextAnalyzer(stopWords: stopWords),
       _reportGenerator = ReportGenerator(outputDirectory: outputDirectory ?? 'reports');

  /// Добавляет файл для анализа
  void addFile(String filePath, {String encoding = 'utf-8'}) {
    _loadManager.addFileLoader(filePath, encoding: encoding);
  }

  /// Добавляет HTTP URL для анализа
  void addUrl(String url, {Map<String, String>? headers, Duration? timeout}) {
    _loadManager.addHttpLoader(url, headers: headers, timeout: timeout);
  }

  /// Добавляет строку для анализа
  void addString(String content, String sourceName) {
    _loadManager.addStringLoader(content, sourceName);
  }

  /// Добавляет JSON файл для анализа
  void addJsonFile(String filePath, {String? contentField, String? sourceField}) {
    _loadManager.addJsonLoader(filePath, contentField: contentField, sourceField: sourceField);
  }

  /// Запускает полный анализ всех источников
  Future<SummaryReport> analyzeAll() async {
    print('🚀 Запуск системы анализа текстов');
    print('📊 Источников данных: ${_loadManager.loaderCount}');
    print('');

    // Этап 1: Загрузка данных
    print('📥 ЭТАП 1: Загрузка данных');
    print('=' * 50);
    final textDataList = await _loadManager.loadAllData();
    
    if (textDataList.isEmpty) {
      throw Exception('Не удалось загрузить данные ни из одного источника');
    }

    print('');
    print('📊 Загружено ${textDataList.length} текстов');
    print('');

    // Этап 2: Анализ текстов
    print('🔍 ЭТАП 2: Анализ текстов');
    print('=' * 50);
    final analysisResults = <AnalysisResult>[];

    for (int i = 0; i < textDataList.length; i++) {
      final textData = textDataList[i];
      print('📄 Анализируем ${i + 1}/${textDataList.length}: ${textData.source}');
      
      try {
        final result = await _analyzer.analyzeText(textData);
        analysisResults.add(result);
      } catch (e) {
        print('❌ Ошибка анализа ${textData.source}: $e');
      }
    }

    if (analysisResults.isEmpty) {
      throw Exception('Не удалось проанализировать ни один текст');
    }

    print('');
    print('✅ Проанализировано ${analysisResults.length} текстов');
    print('');

    // Этап 3: Создание сводного отчета
    print('📊 ЭТАП 3: Создание сводного отчета');
    print('=' * 50);
    final summaryReport = SummaryReport.fromResults(analysisResults);
    
    print('📈 Сводная статистика:');
    print('   📄 Текстов: ${summaryReport.totalTexts}');
    print('   📝 Слов: ${summaryReport.totalWords}');
    print('   🔤 Уникальных слов: ${summaryReport.totalUniqueWords}');
    print('   📖 Средняя читаемость: ${summaryReport.averageReadabilityScore.toStringAsFixed(1)}');
    print('');

    // Этап 4: Генерация отчетов
    print('📄 ЭТАП 4: Генерация отчетов');
    print('=' * 50);
    await _reportGenerator.generateAllReports(summaryReport);

    print('');
    print('🎉 Анализ завершен успешно!');
    print('📁 Отчеты сохранены в директории: ${_reportGenerator.outputDirectory}');
    
    return summaryReport;
  }

  /// Запускает анализ с детальным выводом
  Future<SummaryReport> analyzeWithDetails() async {
    print('🔍 ДЕТАЛЬНЫЙ АНАЛИЗ ТЕКСТОВ');
    print('=' * 60);
    print('');

    final summaryReport = await analyzeAll();

    // Дополнительная детализация
    print('');
    print('📊 ДЕТАЛЬНЫЕ РЕЗУЛЬТАТЫ');
    print('=' * 60);
    
    // Топ слова
    print('🔤 ТОП-10 СЛОВ:');
    for (int i = 0; i < summaryReport.topWords.length && i < 10; i++) {
      final word = summaryReport.topWords[i];
      final frequency = summaryReport.globalWordFrequency[word] ?? 0;
      print('   ${(i + 1).toString().padLeft(2)}. $word ($frequency раз)');
    }
    print('');

    // Самые длинные слова
    print('📏 САМЫЕ ДЛИННЫЕ СЛОВА:');
    for (int i = 0; i < summaryReport.topLongestWords.length && i < 5; i++) {
      final word = summaryReport.topLongestWords[i];
      print('   ${(i + 1).toString().padLeft(2)}. $word (${word.length} символов)');
    }
    print('');

    // Статистика по источникам
    print('📁 СТАТИСТИКА ПО ИСТОЧНИКАМ:');
    for (final entry in summaryReport.resultsBySource.entries) {
      final source = entry.key;
      final results = entry.value;
      final totalWords = results.fold(0, (sum, r) => sum + r.totalWords);
      final avgReadability = results.fold(0.0, (sum, r) => sum + r.readabilityScore) / results.length;
      
      print('   📂 $source:');
      print('      📄 Текстов: ${results.length}');
      print('      📝 Слов: $totalWords');
      print('      📖 Читаемость: ${avgReadability.toStringAsFixed(1)}');
    }
    print('');

    return summaryReport;
  }

  /// Очищает все источники данных
  void clearSources() {
    _loadManager.clear();
  }

  /// Возвращает количество источников
  int get sourceCount => _loadManager.loaderCount;
}

/// Главная функция
void main() async {
  print('🎯 СИСТЕМА АСИНХРОННОГО АНАЛИЗА ТЕКСТОВ');
  print('=' * 60);
  print('');

  try {
    // Создаем систему анализа
    final system = TextAnalysisSystem(
      loadTimeout: const Duration(seconds: 30),
      outputDirectory: 'reports',
    );

    // Добавляем примеры данных для демонстрации
    print('📝 Добавляем примеры данных...');
    
    // Пример 1: Текст из строки
    system.addString(
      'Программирование на Dart - это увлекательный процесс создания современных приложений. '
      'Язык Dart предоставляет мощные инструменты для разработки как мобильных, так и веб-приложений. '
      'Асинхронное программирование позволяет эффективно обрабатывать множество задач одновременно.',
      'Пример текста 1'
    );

    // Пример 2: Еще один текст
    system.addString(
      'Алгоритмы и структуры данных являются основой компьютерной науки. '
      'Эффективные алгоритмы могут значительно ускорить выполнение программ. '
      'Хеш-таблицы, деревья и графы - это важные структуры данных для решения различных задач.',
      'Пример текста 2'
    );

    // Пример 3: Третий текст
    system.addString(
      'Машинное обучение и искусственный интеллект открывают новые возможности в различных областях. '
      'Нейронные сети способны решать сложные задачи распознавания образов. '
      'Глубокое обучение позволяет создавать системы, которые превосходят человека в некоторых задачах.',
      'Пример текста 3'
    );

    print('✅ Добавлено ${system.sourceCount} источников данных');
    print('');

    // Запускаем анализ
    final summaryReport = await system.analyzeWithDetails();

    // Выводим финальную статистику
    print('🎉 АНАЛИЗ ЗАВЕРШЕН УСПЕШНО!');
    print('=' * 60);
    print('📊 Итоговая статистика:');
    print('   📄 Обработано текстов: ${summaryReport.totalTexts}');
    print('   📝 Всего слов: ${summaryReport.totalWords}');
    print('   🔤 Уникальных слов: ${summaryReport.totalUniqueWords}');
    print('   📖 Средняя читаемость: ${summaryReport.averageReadabilityScore.toStringAsFixed(1)}');
    print('   📁 Отчеты сохранены в: reports/');
    print('');

  } catch (e) {
    print('❌ Ошибка выполнения: $e');
    exit(1);
  }
}
