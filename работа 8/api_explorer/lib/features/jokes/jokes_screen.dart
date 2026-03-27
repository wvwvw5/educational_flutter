import 'package:flutter/material.dart';
import '../../core/service_locator.dart';
import 'joke_model.dart';
import 'joke_repository.dart';

class JokesScreen extends StatefulWidget {
  const JokesScreen({super.key});

  @override
  State<JokesScreen> createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  final _repo = getIt<JokeRepository>();

  final List<Joke> _jokes = [];
  bool _loading = false;

  Future<void> _loadJoke() async {
    setState(() => _loading = true);
    try {
      final joke = await _repo.getRandomJoke();
      setState(() {
        _jokes.insert(0, joke);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadJoke();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('😂 Jokes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _loadJoke,
        icon: const Icon(Icons.refresh),
        label: const Text('New Joke'),
      ),
      body: _loading && _jokes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _jokes.isEmpty
              ? const Center(child: Text('Press the button to get a joke!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jokes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Text('${index + 1}'),
                                ),
                                const SizedBox(width: 12),
                                const Text('Random Joke',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _jokes[index].joke,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
