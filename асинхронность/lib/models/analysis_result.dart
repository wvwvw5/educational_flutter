import 'text_data.dart';

/// Результат анализа текста
class AnalysisResult {
  final String textId;
  final String source;
  final Map<String, int> wordFrequency;
  final Map<String, int> characterFrequency;
  final List<String> mostCommonWords;
  final List<String> longestWords;
  final double averageWordLength;
  final int uniqueWords;
  final int totalWords;
  final double readabilityScore;
  final Map<String, dynamic> additionalMetrics;
  final DateTime analysisTime;

  const AnalysisResult({
    required this.textId,
    required this.source,
    required this.wordFrequency,
    required this.characterFrequency,
    required this.mostCommonWords,
    required this.longestWords,
    required this.averageWordLength,
    required this.uniqueWords,
    required this.totalWords,
    required this.readabilityScore,
    this.additionalMetrics = const {},
    required this.analysisTime,
  });

  /// Создает AnalysisResult из TextData
  factory AnalysisResult.fromTextData(TextData textData, {
    Map<String, int>? wordFrequency,
    Map<String, int>? characterFrequency,
    List<String>? mostCommonWords,
    List<String>? longestWords,
    double? averageWordLength,
    int? uniqueWords,
    int? totalWords,
    double? readabilityScore,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return AnalysisResult(
      textId: textData.id,
      source: textData.source,
      wordFrequency: wordFrequency ?? {},
      characterFrequency: characterFrequency ?? {},
      mostCommonWords: mostCommonWords ?? [],
      longestWords: longestWords ?? [],
      averageWordLength: averageWordLength ?? 0.0,
      uniqueWords: uniqueWords ?? 0,
      totalWords: totalWords ?? textData.wordCount,
      readabilityScore: readabilityScore ?? 0.0,
      additionalMetrics: additionalMetrics ?? {},
      analysisTime: DateTime.now(),
    );
  }

  /// Преобразует в Map для сериализации
  Map<String, dynamic> toMap() {
    return {
      'textId': textId,
      'source': source,
      'wordFrequency': wordFrequency,
      'characterFrequency': characterFrequency,
      'mostCommonWords': mostCommonWords,
      'longestWords': longestWords,
      'averageWordLength': averageWordLength,
      'uniqueWords': uniqueWords,
      'totalWords': totalWords,
      'readabilityScore': readabilityScore,
      'additionalMetrics': additionalMetrics,
      'analysisTime': analysisTime.toIso8601String(),
    };
  }

  /// Создает AnalysisResult из Map
  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      textId: map['textId'] as String,
      source: map['source'] as String,
      wordFrequency: Map<String, int>.from(map['wordFrequency'] as Map? ?? {}),
      characterFrequency: Map<String, int>.from(map['characterFrequency'] as Map? ?? {}),
      mostCommonWords: List<String>.from(map['mostCommonWords'] as List? ?? []),
      longestWords: List<String>.from(map['longestWords'] as List? ?? []),
      averageWordLength: (map['averageWordLength'] as num?)?.toDouble() ?? 0.0,
      uniqueWords: map['uniqueWords'] as int? ?? 0,
      totalWords: map['totalWords'] as int? ?? 0,
      readabilityScore: (map['readabilityScore'] as num?)?.toDouble() ?? 0.0,
      additionalMetrics: Map<String, dynamic>.from(map['additionalMetrics'] as Map? ?? {}),
      analysisTime: DateTime.parse(map['analysisTime'] as String),
    );
  }

  @override
  String toString() {
    return 'AnalysisResult(textId: $textId, source: $source, uniqueWords: $uniqueWords, totalWords: $totalWords)';
  }
}
