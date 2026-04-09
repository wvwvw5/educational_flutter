import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int colorValue;
  final int iconCodePoint;
  final int reminderHour;
  final int reminderMinute;
  final bool reminderEnabled;
  final DateTime createdAt;
  final List<DateTime> completedDates;

  const Habit({
    required this.id,
    required this.title,
    this.description,
    required this.colorValue,
    required this.iconCodePoint,
    required this.reminderHour,
    required this.reminderMinute,
    required this.reminderEnabled,
    required this.createdAt,
    required this.completedDates,
  });

  /// True if the habit was completed today (local time).
  bool get isCompletedToday {
    final now = DateTime.now();
    return completedDates.any((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);
  }

  /// Current streak — number of consecutive days including today (or
  /// ending yesterday if today is not yet completed).
  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final normalized = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    DateTime cursor = DateTime(today.year, today.month, today.day);

    if (!normalized.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!normalized.contains(cursor)) return 0;
    }

    while (normalized.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Completions in the last 7 days.
  int get weeklyCount {
    final now = DateTime.now();
    final weekAgo = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return completedDates.where((d) {
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(weekAgo);
    }).length;
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    int? colorValue,
    int? iconCodePoint,
    int? reminderHour,
    int? reminderMinute,
    bool? reminderEnabled,
    DateTime? createdAt,
    List<DateTime>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  /// Stable notification id derived from habit id.
  int get notificationId => id.hashCode & 0x7fffffff;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        colorValue,
        iconCodePoint,
        reminderHour,
        reminderMinute,
        reminderEnabled,
        createdAt,
        completedDates,
      ];
}
