import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.title,
    super.description,
    required super.colorValue,
    required super.iconCodePoint,
    required super.reminderHour,
    required super.reminderMinute,
    required super.reminderEnabled,
    required super.createdAt,
    required super.completedDates,
  });

  factory HabitModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawDates = (data['completedDates'] as List?) ?? const [];
    return HabitModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: data['description'] as String?,
      colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF6750A4,
      iconCodePoint:
          (data['iconCodePoint'] as num?)?.toInt() ?? 0xe3af, // check
      reminderHour: (data['reminderHour'] as num?)?.toInt() ?? 9,
      reminderMinute: (data['reminderMinute'] as num?)?.toInt() ?? 0,
      reminderEnabled: (data['reminderEnabled'] as bool?) ?? false,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completedDates: rawDates
          .whereType<Timestamp>()
          .map((t) => t.toDate())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'reminderEnabled': reminderEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedDates':
          completedDates.map((d) => Timestamp.fromDate(d)).toList(),
    };
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      colorValue: habit.colorValue,
      iconCodePoint: habit.iconCodePoint,
      reminderHour: habit.reminderHour,
      reminderMinute: habit.reminderMinute,
      reminderEnabled: habit.reminderEnabled,
      createdAt: habit.createdAt,
      completedDates: habit.completedDates,
    );
  }
}
