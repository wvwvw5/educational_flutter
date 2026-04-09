import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/habits_bloc.dart';
import '../widgets/habit_card.dart';
import 'create_habit_page.dart';
import 'habit_details_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _HabitsTab(),
      StatisticsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Привычки',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<HabitsBloc>(),
                    child: const CreateHabitPage(),
                  ),
                ));
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            )
          : null,
    );
  }
}

class _HabitsTab extends StatelessWidget {
  const _HabitsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.user != c.user,
          builder: (context, state) {
            final name = state.user?.displayName ?? 'Привет!';
            return Text('Привет, $name');
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<HabitsBloc, HabitsState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage ||
              p.infoMessage != c.infoMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade700,
                  duration: const Duration(seconds: 3),
                ));
            } else if (state.infoMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.infoMessage!),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 2),
                ));
            }
          },
          builder: (context, state) {
            if (state.status == HabitsStatus.loading ||
                state.status == HabitsStatus.initial) {
              return const AppLoader(message: 'Загрузка привычек...');
            }

            return Column(
              children: [
                _ProgressHeader(
                  progress: state.todayProgress,
                  completed: state.completedTodayCount,
                  total: state.habits.length,
                ),
                const SizedBox(height: 8),
                _FilterChips(current: state.filter),
                const SizedBox(height: 8),
                Expanded(
                  child: state.filteredHabits.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: state.filteredHabits.length,
                          itemBuilder: (context, i) {
                            final habit = state.filteredHabits[i];
                            return HabitCard(
                              habit: habit,
                              onToggle: () => context
                                  .read<HabitsBloc>()
                                  .add(HabitCompletionToggled(
                                    habitId: habit.id,
                                    date: DateTime.now(),
                                  )),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<HabitsBloc>(),
                                      child:
                                          HabitDetailsPage(habitId: habit.id),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  const _ProgressHeader({
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF9575CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Прогресс на сегодня',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completed из $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (_, value, __) => SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final HabitsFilter current;
  const _FilterChips({required this.current});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(context, 'Все', HabitsFilter.all),
          const SizedBox(width: 8),
          _chip(context, 'Ожидают', HabitsFilter.pending),
          const SizedBox(width: 8),
          _chip(context, 'Выполнены', HabitsFilter.completed),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, HabitsFilter filter) {
    final selected = current == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => context
          .read<HabitsBloc>()
          .add(HabitsFilterChanged(filter)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_outlined,
                size: 96, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Пока пусто',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первую привычку — и начнём отслеживать прогресс',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
