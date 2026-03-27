import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item.dart';
import '../models/audio_item.dart';

class DatabaseService {
  static const String mediaBoxName = 'media_items';
  static const String audioBoxName = 'audio_items';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MediaItemAdapter());
    Hive.registerAdapter(AudioItemAdapter());
    await Hive.openBox<MediaItem>(mediaBoxName);
    await Hive.openBox<AudioItem>(audioBoxName);
  }

  // Media
  static Box<MediaItem> get mediaBox => Hive.box<MediaItem>(mediaBoxName);

  static Future<void> addMedia(MediaItem item) async {
    await mediaBox.put(item.id, item);
  }

  static List<MediaItem> getAllMedia() {
    final items = mediaBox.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> deleteMedia(String id) async {
    await mediaBox.delete(id);
  }

  // Audio
  static Box<AudioItem> get audioBox => Hive.box<AudioItem>(audioBoxName);

  static Future<void> addAudio(AudioItem item) async {
    await audioBox.put(item.id, item);
  }

  static List<AudioItem> getAllAudio() {
    final items = audioBox.values.toList();
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return items;
  }

  static Future<void> deleteAudio(String id) async {
    await audioBox.delete(id);
  }
}
