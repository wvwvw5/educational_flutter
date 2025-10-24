import 'dart:math';
import '../models/text_data.dart';
import '../models/analysis_result.dart';

/// Эффективная структура данных для подсчета частоты слов
class WordFrequencyCounter {
  final Map<String, int> _frequency = {};
  final Set<String> _stopWords;

  WordFrequencyCounter({Set<String>? stopWords}) 
      : _stopWords = stopWords ?? _defaultStopWords;

  static final Set<String> _defaultStopWords = {
    'и', 'в', 'на', 'с', 'по', 'для', 'от', 'до', 'из', 'к', 'у', 'о', 'об', 'за', 'при',
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by',
    'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did',
    'will', 'would', 'could', 'should', 'may', 'might', 'can', 'must', 'shall'
  };

  /// Добавляет слово в счетчик
  void addWord(String word) {
    final normalizedWord = _normalizeWord(word);
    if (normalizedWord.isNotEmpty && !_stopWords.contains(normalizedWord.toLowerCase())) {
      _frequency[normalizedWord] = (_frequency[normalizedWord] ?? 0) + 1;
    }
  }

  /// Добавляет все слова из текста
  void addText(String text) {
    final words = _extractWords(text);
    for (final word in words) {
      addWord(word);
    }
  }

  /// Нормализует слово (убирает знаки препинания, приводит к нижнему регистру)
  String _normalizeWord(String word) {
    return word.replaceAll(RegExp(r'[^\w\u0400-\u04FF]'), '').toLowerCase();
  }

  /// Извлекает слова из текста
  List<String> _extractWords(String text) {
    return text.split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Возвращает частоту слов
  Map<String, int> get frequency => Map.unmodifiable(_frequency);

  /// Возвращает топ N слов
  List<String> getTopWords(int count) {
    final sortedEntries = _frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(count).map((e) => e.key).toList();
  }

  /// Возвращает общее количество слов
  int get totalWords => _frequency.values.fold(0, (a, b) => a + b);

  /// Возвращает количество уникальных слов
  int get uniqueWords => _frequency.length;
}

/// Эффективная структура данных для подсчета частоты символов
class CharacterFrequencyCounter {
  final Map<String, int> _frequency = {};

  /// Добавляет символ в счетчик
  void addCharacter(String char) {
    _frequency[char] = (_frequency[char] ?? 0) + 1;
  }

  /// Добавляет все символы из текста
  void addText(String text) {
    for (final char in text.runes) {
      addCharacter(String.fromCharCode(char));
    }
  }

  /// Возвращает частоту символов
  Map<String, int> get frequency => Map.unmodifiable(_frequency);

  /// Возвращает топ N символов
  List<String> getTopCharacters(int count) {
    final sortedEntries = _frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(count).map((e) => e.key).toList();
  }
}

/// Анализатор читаемости текста
class ReadabilityAnalyzer {
  /// Вычисляет индекс Флеша-Кинкейда (упрощенная версия)
  static double calculateFleschKincaid(String text) {
    final sentences = _countSentences(text);
    final words = _countWords(text);
    final syllables = _countSyllables(text);

    if (sentences == 0 || words == 0) return 0.0;

    final avgWordsPerSentence = words / sentences;
    final avgSyllablesPerWord = syllables / words;

    return 206.835 - (1.015 * avgWordsPerSentence) - (84.6 * avgSyllablesPerWord);
  }

  /// Подсчитывает количество предложений
  static int _countSentences(String text) {
    return text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
  }

  /// Подсчитывает количество слов
  static int _countWords(String text) {
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  /// Подсчитывает количество слогов (упрощенная версия)
  static int _countSyllables(String text) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    int totalSyllables = 0;

    for (final word in words) {
      totalSyllables += _countSyllablesInWord(word);
    }

    return totalSyllables;
  }

  /// Подсчитывает слоги в слове
  static int _countSyllablesInWord(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    if (cleanWord.isEmpty) return 0;

    int syllables = 0;
    bool previousWasVowel = false;

    for (final char in cleanWord.runes) {
      final isVowel = _isVowel(String.fromCharCode(char));
      if (isVowel && !previousWasVowel) {
        syllables++;
      }
      previousWasVowel = isVowel;
    }

    // Слово должно иметь минимум один слог
    return max(1, syllables);
  }

  /// Проверяет, является ли символ гласной
  static bool _isVowel(String char) {
    const vowels = 'aeiouyаеёиоуыэюя';
    return vowels.contains(char.toLowerCase());
  }
}

/// Основной класс для анализа текста
class TextAnalyzer {
  final Set<String> _stopWords;
  final bool _removeStopWords;
  final bool _calculateReadability;

  TextAnalyzer({
    Set<String>? stopWords,
    bool removeStopWords = true,
    bool calculateReadability = true,
  }) : _stopWords = stopWords ?? {},
       _removeStopWords = removeStopWords,
       _calculateReadability = calculateReadability;

  /// Анализирует текст и возвращает результат
  Future<AnalysisResult> analyzeText(TextData textData) async {
    print('🔍 Анализируем текст: ${textData.source}...');

    // Создаем счетчики
    final wordCounter = WordFrequencyCounter(stopWords: _stopWords);
    final charCounter = CharacterFrequencyCounter();

    // Анализируем текст
    wordCounter.addText(textData.content);
    charCounter.addText(textData.content);

    // Находим самые частые слова
    final mostCommonWords = wordCounter.getTopWords(20);

    // Находим самые длинные слова
    final longestWords = _findLongestWords(textData.content);

    // Вычисляем среднюю длину слова
    final averageWordLength = _calculateAverageWordLength(textData.content);

    // Вычисляем читаемость
    final readabilityScore = _calculateReadability 
        ? ReadabilityAnalyzer.calculateFleschKincaid(textData.content)
        : 0.0;

    // Дополнительные метрики
    final additionalMetrics = {
      'sentenceCount': _countSentences(textData.content),
      'paragraphCount': _countParagraphs(textData.content),
      'averageSentenceLength': _calculateAverageSentenceLength(textData.content),
      'lexicalDiversity': _calculateLexicalDiversity(wordCounter.frequency),
    };

    final result = AnalysisResult(
      textId: textData.id,
      source: textData.source,
      wordFrequency: wordCounter.frequency,
      characterFrequency: charCounter.frequency,
      mostCommonWords: mostCommonWords,
      longestWords: longestWords,
      averageWordLength: averageWordLength,
      uniqueWords: wordCounter.uniqueWords,
      totalWords: wordCounter.totalWords,
      readabilityScore: readabilityScore,
      additionalMetrics: additionalMetrics,
      analysisTime: DateTime.now(),
    );

    print('✅ Анализ завершен: ${result.uniqueWords} уникальных слов, читаемость: ${readabilityScore.toStringAsFixed(1)}');
    return result;
  }

  /// Находит самые длинные слова
  List<String> _findLongestWords(String text) {
    final words = text.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.replaceAll(RegExp(r'[^\w\u0400-\u04FF]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();

    words.sort((a, b) => b.length.compareTo(a.length));
    return words.take(10).toList();
  }

  /// Вычисляет среднюю длину слова
  double _calculateAverageWordLength(String text) {
    final words = text.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.replaceAll(RegExp(r'[^\w\u0400-\u04FF]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty) return 0.0;

    final totalLength = words.fold(0, (sum, word) => sum + word.length);
    return totalLength / words.length;
  }

  /// Подсчитывает количество предложений
  int _countSentences(String text) {
    return text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
  }

  /// Подсчитывает количество абзацев
  int _countParagraphs(String text) {
    return text.split('\n\n').where((p) => p.trim().isNotEmpty).length;
  }

  /// Вычисляет среднюю длину предложения
  double _calculateAverageSentenceLength(String text) {
    final sentences = _countSentences(text);
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return sentences > 0 ? words / sentences : 0.0;
  }

  /// Вычисляет лексическое разнообразие
  double _calculateLexicalDiversity(Map<String, int> wordFrequency) {
    final totalWords = wordFrequency.values.fold(0, (a, b) => a + b);
    if (totalWords == 0) return 0.0;
    return wordFrequency.length / totalWords;
  }
}
