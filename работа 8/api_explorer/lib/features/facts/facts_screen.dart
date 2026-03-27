import 'package:flutter/material.dart';
import '../../core/service_locator.dart';
import 'fact_model.dart';
import 'fact_repository.dart';

class FactsScreen extends StatefulWidget {
  const FactsScreen({super.key});

  @override
  State<FactsScreen> createState() => _FactsScreenState();
}

class _FactsScreenState extends State<FactsScreen> with SingleTickerProviderStateMixin {
  final _repo = getIt<FactRepository>();

  final List<Fact> _facts = [];
  bool _loading = false;
  late AnimationController _animController;

  Future<void> _loadFact() async {
    setState(() => _loading = true);
    try {
      final fact = await _repo.getRandomFact();
      setState(() {
        _facts.insert(0, fact);
        _loading = false;
      });
      _animController.forward(from: 0);
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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadFact();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Random Facts'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_facts.length} facts',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _loadFact,
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.lightbulb_outline),
        label: const Text('New Fact'),
      ),
      body: _facts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _facts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: index == 0 ? theme.colorScheme.primaryContainer : null,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: index == 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: index == 0 ? theme.colorScheme.onPrimary : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _facts[index].text,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: index == 0 ? FontWeight.w500 : null,
                            ),
                          ),
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
