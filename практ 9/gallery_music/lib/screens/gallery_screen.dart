import 'dart:io' if (dart.library.html) 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/media_item.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../widgets/video_player_widget.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<MediaItem> _items = [];
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = DatabaseService.getAllMedia();
    });
  }

  Future<void> _addMedia(MediaType type) async {
    setState(() => _isLoading = true);

    try {
      XFile? file;
      if (type == MediaType.photo) {
        file = await _picker.pickImage(source: ImageSource.gallery);
      } else {
        file = await _picker.pickVideo(source: ImageSource.gallery);
      }

      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get location
      double? lat, lng;
      String? locationName;
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        locationName =
            await LocationService.getLocationName(lat, lng);
      }

      final item = MediaItem(
        id: const Uuid().v4(),
        path: file.path,
        type: type,
        createdAt: DateTime.now(),
        latitude: lat,
        longitude: lng,
        locationName: locationName,
      );

      await DatabaseService.addMedia(item);
      _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }

      double? lat, lng;
      String? locationName;
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        locationName = await LocationService.getLocationName(lat, lng);
      }

      final item = MediaItem(
        id: const Uuid().v4(),
        path: file.path,
        type: MediaType.photo,
        createdAt: DateTime.now(),
        latitude: lat,
        longitude: lng,
        locationName: locationName,
      );

      await DatabaseService.addMedia(item);
      _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(MediaItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.deleteMedia(item.id);
      _loadItems();
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose photo from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(MediaType.photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Choose video from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(MediaType.video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Gallery is empty',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Tap + to add photos and videos',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _FeedCard(
                      item: item,
                      onDelete: () => _deleteItem(item),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onDelete;

  const _FeedCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  item.type == MediaType.photo
                      ? Icons.photo
                      : Icons.videocam,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type == MediaType.photo ? 'Photo' : 'Video',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),

          // Media content
          if (item.type == MediaType.photo)
            kIsWeb
                ? Image.network(
                    item.path,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 48)),
                    ),
                  )
                : Image.file(
                    File(item.path),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 48)),
                    ),
                  )
          else if (!kIsWeb)
            VideoPlayerWidget(videoPath: item.path)
          else
            Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Video (mobile only)'),
                  ],
                ),
              ),
            ),

          // Location info
          if (item.locationName != null || item.latitude != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.locationName ??
                          '${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
