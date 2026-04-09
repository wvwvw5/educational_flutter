import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/habits_bloc.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: SafeArea(
        child: BlocBuilder<HabitsBloc, HabitsState>(
          builder: (context, state) {
            if (state.habits.isEmpty) {
              return Center(
                child: Text(
                  'Добавьте привычки, чтобы увидеть статистику',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            final now = DateTime.now();
            final labels = <String>[];
            final counts = <int>[];
            for (int i = 6; i >= 0; i--) {
              final day = DateTime(now.year, now.month, now.day)
                  .subtract(Duration(days: i));
              labels.add(DateFormat('E', 'ru_RU').format(day));
              int done = 0;
              for (final habit in state.habits) {
                if (habit.completedDates.any((d) =>
                    d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day)) {
                  done++;
                }
              }
              counts.add(done);
            }

            final maxY = (state.habits.length).toDouble().clamp(1, 100);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(
                    total: state.habits.length,
                    completedToday: state.completedTodayCount,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'За последние 7 дней',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY.toDouble(),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 11),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[i],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(counts.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: counts[i].toDouble(),
                                color: AppColors.primary,
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Топ привычек по серии',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...([...state.habits]
                        ..sort((a, b) =>
                            b.currentStreak.compareTo(a.currentStreak)))
                      .take(5)
                      .map(
                        (h) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(h.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  h.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.local_fire_department,
                                  size: 16,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 4),
                              Text(
                                '${h.currentStreak}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int total;
  final int completedToday;
  const _HeaderCard({required this.total, required this.completedToday});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric('Всего', '$total'),
          _metric('Сегодня', '$completedToday'),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
