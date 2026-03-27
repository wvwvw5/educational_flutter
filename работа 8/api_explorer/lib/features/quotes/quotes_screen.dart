import 'package:flutter/material.dart';
import '../../core/service_locator.dart';
import 'quote_model.dart';
import 'quote_repository.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final _repo = getIt<QuoteRepository>();

  List<Quote> _quotes = [];
  bool _loading = false;
  String? _selectedCategory;

  Future<void> _loadQuotes() async {
    setState(() => _loading = true);
    try {
      final quotes = await _repo.getQuotes(category: _selectedCategory);
      setState(() {
        _quotes = quotes;
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
    _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 Quotes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _loadQuotes,
        child: const Icon(Icons.refresh),
      ),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() => _selectedCategory = null);
                      _loadQuotes();
                    },
                  ),
                ),
                ...QuoteRepository.categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          _loadQuotes();
                        },
                      ),
                    )),
              ],
            ),
          ),
          const Divider(),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _quotes.isEmpty
                  ? const Center(child: Text('No quotes found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _quotes.length,
                      itemBuilder: (context, index) {
                        final quote = _quotes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${quote.text}"',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '— ${quote.author}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    if (quote.category.isNotEmpty)
                                      Chip(
                                        label: Text(quote.category, style: const TextStyle(fontSize: 11)),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ],
                            ),
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
