import 'package:flutter/material.dart';
import '../../core/service_locator.dart';
import 'animal_model.dart';
import 'animal_repository.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final _controller = TextEditingController();
  final _repo = getIt<AnimalRepository>();

  List<Animal> _animals = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await _repo.searchAnimals(query);
      setState(() {
        _animals = results;
        _loading = false;
        if (results.isEmpty) _error = 'No animals found for "$query"';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🐾 Animals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Search animal (e.g., lion, eagle)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _animals.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final animal = _animals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const CircleAvatar(child: Icon(Icons.pets)),
                    title: Text(
                      animal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(animal.taxonomy, maxLines: 1, overflow: TextOverflow.ellipsis),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (animal.locations.isNotEmpty) ...[
                              const Text('Locations:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: animal.locations
                                    .map((l) => Chip(label: Text(l, style: const TextStyle(fontSize: 12))))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (animal.lifespan != null) ...[
                              Text('Lifespan: ${animal.lifespan}'),
                              const SizedBox(height: 8),
                            ],
                            const Text('Characteristics:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(animal.characteristics),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
