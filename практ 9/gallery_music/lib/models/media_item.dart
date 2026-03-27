import 'package:hive/hive.dart';

enum MediaType { photo, video }

class MediaItem {
  final String id;
  final String path;
  final MediaType type;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  MediaItem({
    required this.id,
    required this.path,
    required this.type,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'path': path,
        'type': type.index,
        'createdAt': createdAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
      };

  factory MediaItem.fromMap(Map<dynamic, dynamic> map) => MediaItem(
        id: map['id'] as String,
        path: map['path'] as String,
        type: MediaType.values[map['type'] as int],
        createdAt: DateTime.parse(map['createdAt'] as String),
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        locationName: map['locationName'] as String?,
      );
}

class MediaItemAdapter extends TypeAdapter<MediaItem> {
  @override
  final int typeId = 0;

  @override
  MediaItem read(BinaryReader reader) {
    final map = reader.readMap();
    return MediaItem.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, MediaItem obj) {
    writer.writeMap(obj.toMap());
  }
}
