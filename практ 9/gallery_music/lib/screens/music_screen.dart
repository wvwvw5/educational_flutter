import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/audio_item.dart';
import '../services/database_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List<AudioItem> _tracks = [];
  final AudioPlayer _player = AudioPlayer();
  String? _currentTrackId;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTracks();

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => _duration = dur);
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _position = Duration.zero;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _loadTracks() {
    setState(() {
      _tracks = DatabaseService.getAllAudio();
    });
  }

  Future<void> _addFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final item = AudioItem(
      id: const Uuid().v4(),
      title: file.name,
      path: file.path!,
      source: AudioOrigin.file,
      addedAt: DateTime.now(),
    );

    await DatabaseService.addAudio(item);
    _loadTracks();
  }

  Future<void> _addFromUrl() async {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add audio from URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'My favorite track',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com/audio.mp3',
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true &&
        urlController.text.isNotEmpty &&
        titleController.text.isNotEmpty) {
      final item = AudioItem(
        id: const Uuid().v4(),
        title: titleController.text,
        path: urlController.text,
        source: AudioOrigin.url,
        addedAt: DateTime.now(),
      );

      await DatabaseService.addAudio(item);
      _loadTracks();
    }

    urlController.dispose();
    titleController.dispose();
  }

  Future<void> _playTrack(AudioItem track) async {
    try {
      if (_currentTrackId == track.id) {
        if (_isPlaying) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }

      _currentTrackId = track.id;
      if (track.source == AudioOrigin.url) {
        await _player.setUrl(track.path);
      } else {
        await _player.setFilePath(track.path);
      }
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTrack(AudioItem track) async {
    if (_currentTrackId == track.id) {
      await _player.stop();
      _currentTrackId = null;
    }
    await DatabaseService.deleteAudio(track.id);
    _loadTracks();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Player bar
          if (_currentTrackId != null) _buildPlayerBar(),

          // Track list
          Expanded(
            child: _tracks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No music yet',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Tap + to add tracks',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _tracks.length,
                    itemBuilder: (context, index) {
                      final track = _tracks[index];
                      final isActive = _currentTrackId == track.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? Colors.deepPurple
                              : Colors.grey.shade200,
                          child: Icon(
                            isActive && _isPlaying
                                ? Icons.pause
                                : Icons.music_note,
                            color: isActive ? Colors.white : Colors.grey,
                          ),
                        ),
                        title: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? Colors.deepPurple : null,
                          ),
                        ),
                        subtitle: Text(
                          track.source == AudioOrigin.url
                              ? 'URL: ${track.path}'
                              : 'Local file',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteTrack(track),
                        ),
                        onTap: () => _playTrack(track),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlayerBar() {
    final currentTrack = _tracks.where((t) => t.id == _currentTrackId);
    final title =
        currentTrack.isNotEmpty ? currentTrack.first.title : 'Unknown';

    return Container(
      color: Colors.deepPurple.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () async {
                  await _player.stop();
                  setState(() {
                    _currentTrackId = null;
                    _position = Duration.zero;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _duration.inMilliseconds > 0
                      ? _position.inMilliseconds
                          .clamp(0, _duration.inMilliseconds)
                          .toDouble()
                      : 0,
                  max: _duration.inMilliseconds > 0
                      ? _duration.inMilliseconds.toDouble()
                      : 1,
                  onChanged: (value) {
                    _player.seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Load audio file'),
              onTap: () {
                Navigator.pop(ctx);
                _addFromFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add URL link'),
              onTap: () {
                Navigator.pop(ctx);
                _addFromUrl();
              },
            ),
          ],
        ),
      ),
    );
  }
}
