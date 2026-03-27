import 'package:hive/hive.dart';

enum AudioOrigin { file, url }

class AudioItem {
  final String id;
  final String title;
  final String path; // file path or URL
  final AudioOrigin source;
  final DateTime addedAt;

  AudioItem({
    required this.id,
    required this.title,
    required this.path,
    required this.source,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'path': path,
        'source': source.index,
        'addedAt': addedAt.toIso8601String(),
      };

  factory AudioItem.fromMap(Map<dynamic, dynamic> map) => AudioItem(
        id: map['id'] as String,
        title: map['title'] as String,
        path: map['path'] as String,
        source: AudioOrigin.values[map['source'] as int],
        addedAt: DateTime.parse(map['addedAt'] as String),
      );
}

class AudioItemAdapter extends TypeAdapter<AudioItem> {
  @override
  final int typeId = 1;

  @override
  AudioItem read(BinaryReader reader) {
    final map = reader.readMap();
    return AudioItem.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, AudioItem obj) {
    writer.writeMap(obj.toMap());
  }
}
