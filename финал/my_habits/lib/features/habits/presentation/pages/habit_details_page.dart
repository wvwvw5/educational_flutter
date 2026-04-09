import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/habit.dart';
import '../bloc/habits_bloc.dart';
import 'create_habit_page.dart';

class HabitDetailsPage extends StatelessWidget {
  final String habitId;
  const HabitDetailsPage({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsBloc, HabitsState>(
      builder: (context, state) {
        final habit = state.habits.firstWhere(
          (h) => h.id == habitId,
          orElse: () => Habit(
            id: habitId,
            title: 'Привычка не найдена',
            colorValue: 0xFF9E9E9E,
            iconCodePoint: Icons.help_outline.codePoint,
            reminderHour: 0,
            reminderMinute: 0,
            reminderEnabled: false,
            createdAt: DateTime.now(),
            completedDates: const [],
          ),
        );
        final color = Color(habit.colorValue);

        return Scaffold(
          appBar: AppBar(
            title: Text(habit.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<HabitsBloc>(),
                      child: CreateHabitPage(existing: habit),
                    ),
                  ));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, habit),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            IconData(habit.iconCodePoint,
                                fontFamily: 'MaterialIcons'),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (habit.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  habit.description!,
                                  style: TextStyle(
                                      color: Colors.grey.shade700),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Серия',
                        value: '${habit.currentStreak}',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.date_range,
                        label: 'За неделю',
                        value: '${habit.weeklyCount}',
                        color: color,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Всего',
                        value: '${habit.completedDates.length}',
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Последние 30 дней',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _CalendarGrid(habit: habit, color: color),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    onPressed: () => context.read<HabitsBloc>().add(
                          HabitCompletionToggled(
                            habitId: habit.id,
                            date: DateTime.now(),
                          ),
                        ),
                    icon: Icon(
                      habit.isCompletedToday
                          ? Icons.undo
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      habit.isCompletedToday
                          ? 'Снять отметку'
                          : 'Отметить выполнение',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content: Text('Привычка "${habit.title}" и вся её история будут '
            'безвозвратно удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<HabitsBloc>().add(HabitDeleted(habit.id));
      Navigator.of(context).pop();
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final Habit habit;
  final Color color;
  const _CalendarGrid({required this.habit, required this.color});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(
      30,
      (i) => today.subtract(Duration(days: 29 - i)),
    );
    final completedSet = habit.completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final done = completedSet.contains(day);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: done ? color : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              DateFormat('d').format(day),
              style: TextStyle(
                fontSize: 12,
                color: done ? Colors.white : Colors.grey.shade700,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}
