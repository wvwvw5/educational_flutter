import 'dart:io';
import 'dart:convert';
import '../models/analysis_result.dart';
import '../models/summary_report.dart';

/// Генератор отчетов
class ReportGenerator {
  final String outputDirectory;
  final bool generateJson;
  final bool generateHtml;
  final bool generateCsv;

  ReportGenerator({
    this.outputDirectory = 'reports',
    this.generateJson = true,
    this.generateHtml = true,
    this.generateCsv = true,
  });

  /// Генерирует все отчеты из сводного отчета
  Future<void> generateAllReports(SummaryReport report) async {
    print('📊 Генерируем отчеты...');
    
    // Создаем директорию для отчетов
    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final baseFileName = 'report_$timestamp';

    // Генерируем различные форматы отчетов
    if (generateJson) {
      await _generateJsonReport(report, '$outputDirectory/${baseFileName}.json');
    }

    if (generateHtml) {
      await _generateHtmlReport(report, '$outputDirectory/${baseFileName}.html');
    }

    if (generateCsv) {
      await _generateCsvReport(report, '$outputDirectory/${baseFileName}.csv');
    }

    // Генерируем детальный текстовый отчет
    await _generateTextReport(report, '$outputDirectory/${baseFileName}.txt');

    print('✅ Отчеты сгенерированы в директории: $outputDirectory');
  }

  /// Генерирует JSON отчет
  Future<void> _generateJsonReport(SummaryReport report, String filePath) async {
    final jsonData = {
      'summary': {
        'generatedAt': report.generatedAt.toIso8601String(),
        'totalTexts': report.totalTexts,
        'totalWords': report.totalWords,
        'totalUniqueWords': report.totalUniqueWords,
        'averageReadabilityScore': report.averageReadabilityScore,
        'statistics': report.statistics,
      },
      'topWords': report.topWords,
      'topLongestWords': report.topLongestWords,
      'globalWordFrequency': report.globalWordFrequency,
      'resultsBySource': report.resultsBySource.map((source, results) => 
        MapEntry(source, results.map((r) => r.toMap()).toList())),
      'detailedResults': report.results.map((r) => r.toMap()).toList(),
    };

    final file = File(filePath);
    await file.writeAsString(jsonEncode(jsonData));
    print('📄 JSON отчет: $filePath');
  }

  /// Генерирует HTML отчет
  Future<void> _generateHtmlReport(SummaryReport report, String filePath) async {
    final html = '''
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Отчет анализа текстов</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1, h2, h3 { color: #333; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #007bff; }
        .stat-value { font-size: 24px; font-weight: bold; color: #007bff; }
        .stat-label { color: #666; font-size: 14px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; font-weight: bold; }
        .word-cloud { display: flex; flex-wrap: wrap; gap: 5px; margin: 20px 0; }
        .word-tag { background: #e3f2fd; padding: 5px 10px; border-radius: 15px; font-size: 12px; }
        .source-section { margin: 30px 0; padding: 20px; background: #f8f9fa; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Отчет анализа текстов</h1>
        <p><strong>Сгенерирован:</strong> ${report.generatedAt.toString()}</p>
        
        <h2>📈 Общая статистика</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value">${report.totalTexts}</div>
                <div class="stat-label">Всего текстов</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">${report.totalWords}</div>
                <div class="stat-label">Всего слов</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">${report.totalUniqueWords}</div>
                <div class="stat-label">Уникальных слов</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">${report.averageReadabilityScore.toStringAsFixed(1)}</div>
                <div class="stat-label">Средняя читаемость</div>
            </div>
        </div>

        <h2>🔤 Топ слова</h2>
        <div class="word-cloud">
            ${report.topWords.take(30).map((word) => '<span class="word-tag">$word</span>').join('')}
        </div>

        <h2>📝 Самые длинные слова</h2>
        <div class="word-cloud">
            ${report.topLongestWords.take(10).map((word) => '<span class="word-tag">$word (${word.length})</span>').join('')}
        </div>

        <h2>📊 Детальная статистика</h2>
        <table>
            <tr><th>Метрика</th><th>Значение</th></tr>
            ${report.statistics.entries.map((e) => '<tr><td>${e.key}</td><td>${e.value}</td></tr>').join('')}
        </table>

        <h2>📁 Результаты по источникам</h2>
        ${report.resultsBySource.entries.map((entry) => '''
        <div class="source-section">
            <h3>${entry.key}</h3>
            <p><strong>Количество текстов:</strong> ${entry.value.length}</p>
            <p><strong>Общее количество слов:</strong> ${entry.value.fold(0, (sum, r) => sum + r.totalWords)}</p>
            <p><strong>Средняя читаемость:</strong> ${(entry.value.fold(0.0, (sum, r) => sum + r.readabilityScore) / entry.value.length).toStringAsFixed(1)}</p>
        </div>
        ''').join('')}
    </div>
</body>
</html>
    ''';

    final file = File(filePath);
    await file.writeAsString(html);
    print('🌐 HTML отчет: $filePath');
  }

  /// Генерирует CSV отчет
  Future<void> _generateCsvReport(SummaryReport report, String filePath) async {
    final csvLines = <String>[];
    
    // Заголовок
    csvLines.add('Source,TextId,TotalWords,UniqueWords,ReadabilityScore,AverageWordLength');
    
    // Данные по каждому тексту
    for (final result in report.results) {
      csvLines.add('${result.source},${result.textId},${result.totalWords},${result.uniqueWords},${result.readabilityScore.toStringAsFixed(2)},${result.averageWordLength.toStringAsFixed(2)}');
    }
    
    // Сводная статистика
    csvLines.add('');
    csvLines.add('SUMMARY');
    csvLines.add('TotalTexts,${report.totalTexts}');
    csvLines.add('TotalWords,${report.totalWords}');
    csvLines.add('TotalUniqueWords,${report.totalUniqueWords}');
    csvLines.add('AverageReadability,${report.averageReadabilityScore.toStringAsFixed(2)}');
    
    final file = File(filePath);
    await file.writeAsString(csvLines.join('\n'));
    print('📊 CSV отчет: $filePath');
  }

  /// Генерирует текстовый отчет
  Future<void> _generateTextReport(SummaryReport report, String filePath) async {
    final lines = <String>[];
    
    lines.add('=' * 80);
    lines.add('📊 ОТЧЕТ АНАЛИЗА ТЕКСТОВ');
    lines.add('=' * 80);
    lines.add('');
    lines.add('🕒 Сгенерирован: ${report.generatedAt.toString()}');
    lines.add('');
    
    // Общая статистика
    lines.add('📈 ОБЩАЯ СТАТИСТИКА');
    lines.add('-' * 40);
    lines.add('📄 Всего текстов: ${report.totalTexts}');
    lines.add('📝 Всего слов: ${report.totalWords}');
    lines.add('🔤 Уникальных слов: ${report.totalUniqueWords}');
    lines.add('📖 Средняя читаемость: ${report.averageReadabilityScore.toStringAsFixed(1)}');
    lines.add('');
    
    // Топ слова
    lines.add('🔤 ТОП-20 СЛОВ');
    lines.add('-' * 40);
    for (int i = 0; i < report.topWords.length && i < 20; i++) {
      final word = report.topWords[i];
      final frequency = report.globalWordFrequency[word] ?? 0;
      lines.add('${(i + 1).toString().padLeft(2)}. $word ($frequency раз)');
    }
    lines.add('');
    
    // Самые длинные слова
    lines.add('📏 САМЫЕ ДЛИННЫЕ СЛОВА');
    lines.add('-' * 40);
    for (int i = 0; i < report.topLongestWords.length && i < 10; i++) {
      final word = report.topLongestWords[i];
      lines.add('${(i + 1).toString().padLeft(2)}. $word (${word.length} символов)');
    }
    lines.add('');
    
    // Детальная статистика
    lines.add('📊 ДЕТАЛЬНАЯ СТАТИСТИКА');
    lines.add('-' * 40);
    for (final entry in report.statistics.entries) {
      lines.add('${entry.key}: ${entry.value}');
    }
    lines.add('');
    
    // Результаты по источникам
    lines.add('📁 РЕЗУЛЬТАТЫ ПО ИСТОЧНИКАМ');
    lines.add('-' * 40);
    for (final entry in report.resultsBySource.entries) {
      final source = entry.key;
      final results = entry.value;
      final totalWords = results.fold(0, (sum, r) => sum + r.totalWords);
      final avgReadability = results.fold(0.0, (sum, r) => sum + r.readabilityScore) / results.length;
      
      lines.add('📂 $source:');
      lines.add('   📄 Текстов: ${results.length}');
      lines.add('   📝 Слов: $totalWords');
      lines.add('   📖 Читаемость: ${avgReadability.toStringAsFixed(1)}');
      lines.add('');
    }
    
    lines.add('=' * 80);
    lines.add('Отчет завершен');
    lines.add('=' * 80);
    
    final file = File(filePath);
    await file.writeAsString(lines.join('\n'));
    print('📄 Текстовый отчет: $filePath');
  }
}
