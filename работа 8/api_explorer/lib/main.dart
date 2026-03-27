import 'package:flutter/material.dart';
import 'core/service_locator.dart';
import 'features/animals/animals_screen.dart';
import 'features/jokes/jokes_screen.dart';
import 'features/quotes/quotes_screen.dart';
import 'features/facts/facts_screen.dart';
import 'features/recipes/recipes_screen.dart';

void main() {
  setupServiceLocator();
  runApp(const ApiExplorerApp());
}

class ApiExplorerApp extends StatelessWidget {
  const ApiExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    AnimalsScreen(),
    RecipesScreen(),
    QuotesScreen(),
    FactsScreen(),
    JokesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Animals'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Recipes'),
          NavigationDestination(icon: Icon(Icons.format_quote), label: 'Quotes'),
          NavigationDestination(icon: Icon(Icons.lightbulb), label: 'Facts'),
          NavigationDestination(icon: Icon(Icons.mood), label: 'Jokes'),
        ],
      ),
    );
  }
}
