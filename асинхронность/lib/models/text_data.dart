/// Модель для хранения текстовых данных
class TextData {
  final String id;
  final String content;
  final String source;
  final DateTime timestamp;
  final int wordCount;
  final int characterCount;
  final Map<String, dynamic> metadata;

  const TextData({
    required this.id,
    required this.content,
    required this.source,
    required this.timestamp,
    required this.wordCount,
    required this.characterCount,
    this.metadata = const {},
  });

  /// Создает TextData из строки
  factory TextData.fromString(String content, String source, {String? id}) {
    final words = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final characters = content.length;
    
    return TextData(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      source: source,
      timestamp: DateTime.now(),
      wordCount: words,
      characterCount: characters,
    );
  }

  /// Преобразует в Map для сериализации
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'wordCount': wordCount,
      'characterCount': characterCount,
      'metadata': metadata,
    };
  }

  /// Создает TextData из Map
  factory TextData.fromMap(Map<String, dynamic> map) {
    return TextData(
      id: map['id'] as String,
      content: map['content'] as String,
      source: map['source'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      wordCount: map['wordCount'] as int,
      characterCount: map['characterCount'] as int,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'TextData(id: $id, source: $source, words: $wordCount, chars: $characterCount)';
  }
}
