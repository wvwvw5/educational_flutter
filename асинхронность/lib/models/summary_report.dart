import 'dart:math' as math;
import 'analysis_result.dart';

/// Сводный отчет по анализу всех текстов
class SummaryReport {
  final List<AnalysisResult> results;
  final DateTime generatedAt;
  final Map<String, int> globalWordFrequency;
  final Map<String, int> globalCharacterFrequency;
  final List<String> topWords;
  final List<String> topLongestWords;
  final double averageReadabilityScore;
  final int totalTexts;
  final int totalWords;
  final int totalUniqueWords;
  final Map<String, dynamic> statistics;
  final Map<String, List<AnalysisResult>> resultsBySource;

  const SummaryReport({
    required this.results,
    required this.generatedAt,
    required this.globalWordFrequency,
    required this.globalCharacterFrequency,
    required this.topWords,
    required this.topLongestWords,
    required this.averageReadabilityScore,
    required this.totalTexts,
    required this.totalWords,
    required this.totalUniqueWords,
    required this.statistics,
    required this.resultsBySource,
  });

  /// Создает SummaryReport из списка результатов анализа
  factory SummaryReport.fromResults(List<AnalysisResult> results) {
    final generatedAt = DateTime.now();
    
    // Объединяем частоты слов
    final globalWordFrequency = <String, int>{};
    final globalCharacterFrequency = <String, int>{};
    final resultsBySource = <String, List<AnalysisResult>>{};
    
    int totalWords = 0;
    int totalUniqueWords = 0;
    double totalReadabilityScore = 0.0;
    
    for (final result in results) {
      // Объединяем частоты слов
      for (final entry in result.wordFrequency.entries) {
        globalWordFrequency[entry.key] = 
            (globalWordFrequency[entry.key] ?? 0) + entry.value;
      }
      
      // Объединяем частоты символов
      for (final entry in result.characterFrequency.entries) {
        globalCharacterFrequency[entry.key] = 
            (globalCharacterFrequency[entry.key] ?? 0) + entry.value;
      }
      
      // Группируем по источникам
      resultsBySource.putIfAbsent(result.source, () => []).add(result);
      
      totalWords += result.totalWords;
      totalUniqueWords += result.uniqueWords;
      totalReadabilityScore += result.readabilityScore;
    }
    
    // Находим топ слова
    final sortedWords = globalWordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topWords = sortedWords.take(20).map((e) => e.key).toList();
    
    // Находим самые длинные слова
    final allLongestWords = <String>[];
    for (final result in results) {
      allLongestWords.addAll(result.longestWords);
    }
    allLongestWords.sort((a, b) => b.length.compareTo(a.length));
    final topLongestWords = allLongestWords.take(10).toList();
    
    // Статистика
    final statistics = <String, dynamic>{
      'averageWordsPerText': totalWords / results.length,
      'averageUniqueWordsPerText': totalUniqueWords / results.length,
      'mostProductiveSource': _findMostProductiveSource(resultsBySource),
      'totalCharacters': globalCharacterFrequency.values.fold(0, (a, b) => a + b),
      'diversityScore': _calculateDiversityScore(globalWordFrequency),
    };
    
    return SummaryReport(
      results: results,
      generatedAt: generatedAt,
      globalWordFrequency: globalWordFrequency,
      globalCharacterFrequency: globalCharacterFrequency,
      topWords: topWords,
      topLongestWords: topLongestWords,
      averageReadabilityScore: totalReadabilityScore / results.length,
      totalTexts: results.length,
      totalWords: totalWords,
      totalUniqueWords: totalUniqueWords,
      statistics: statistics,
      resultsBySource: resultsBySource,
    );
  }
  
  /// Находит самый продуктивный источник
  static String _findMostProductiveSource(Map<String, List<AnalysisResult>> resultsBySource) {
    String mostProductive = '';
    int maxWords = 0;
    
    for (final entry in resultsBySource.entries) {
      final totalWords = entry.value.fold(0, (sum, result) => sum + result.totalWords);
      if (totalWords > maxWords) {
        maxWords = totalWords;
        mostProductive = entry.key;
      }
    }
    
    return mostProductive;
  }
  
  /// Вычисляет показатель разнообразия словаря
  static double _calculateDiversityScore(Map<String, int> wordFrequency) {
    final totalWords = wordFrequency.values.fold(0, (a, b) => a + b);
    if (totalWords == 0) return 0.0;
    
    double entropy = 0.0;
    for (final count in wordFrequency.values) {
      final probability = count / totalWords;
      if (probability > 0) {
        entropy -= probability * (math.log(probability));
      }
    }
    
    return entropy;
  }

  /// Преобразует в Map для сериализации
  Map<String, dynamic> toMap() {
    return {
      'results': results.map((r) => r.toMap()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'globalWordFrequency': globalWordFrequency,
      'globalCharacterFrequency': globalCharacterFrequency,
      'topWords': topWords,
      'topLongestWords': topLongestWords,
      'averageReadabilityScore': averageReadabilityScore,
      'totalTexts': totalTexts,
      'totalWords': totalWords,
      'totalUniqueWords': totalUniqueWords,
      'statistics': statistics,
      'resultsBySource': resultsBySource.map((k, v) => MapEntry(k, v.map((r) => r.toMap()).toList())),
    };
  }

  @override
  String toString() {
    return 'SummaryReport(totalTexts: $totalTexts, totalWords: $totalWords, averageReadability: ${averageReadabilityScore.toStringAsFixed(2)})';
  }
}
