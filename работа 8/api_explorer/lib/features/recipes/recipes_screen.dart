import 'package:flutter/material.dart';
import '../../core/service_locator.dart';
import 'recipe_model.dart';
import 'recipe_repository.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _controller = TextEditingController();
  final _repo = getIt<RecipeRepository>();

  List<Recipe> _recipes = [];
  bool _loading = false;
  String? _error;

  final _quickSearches = ['pasta', 'chicken', 'salad', 'soup', 'cake', 'rice'];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    _controller.text = query;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await _repo.searchRecipes(query.trim());
      setState(() {
        _recipes = results;
        _loading = false;
        if (results.isEmpty) _error = 'No recipes found for "$query"';
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
      appBar: AppBar(title: const Text('🍳 Recipes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search recipes (e.g., pasta, chicken)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              onSubmitted: _search,
            ),
          ),
          // Quick search chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _quickSearches
                  .map((q) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(
                          label: Text(q),
                          onPressed: () => _search(q),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _recipes.isEmpty && !_loading && _error == null
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Search for a recipe to get started'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          title: Text(
                            recipe.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Servings: ${recipe.servings}'),
                          leading: const CircleAvatar(child: Icon(Icons.food_bank)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ingredients:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(recipe.ingredients, style: const TextStyle(height: 1.5)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Instructions:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(recipe.instructions, style: const TextStyle(height: 1.6)),
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
