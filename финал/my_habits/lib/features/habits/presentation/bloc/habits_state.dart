part of 'habits_bloc.dart';

enum HabitsStatus { initial, loading, loaded, error }

enum HabitsFilter { all, pending, completed }

class HabitsState extends Equatable {
  final HabitsStatus status;
  final List<Habit> habits;
  final HabitsFilter filter;
  final String? errorMessage;
  final String? infoMessage;

  const HabitsState({
    this.status = HabitsStatus.initial,
    this.habits = const [],
    this.filter = HabitsFilter.all,
    this.errorMessage,
    this.infoMessage,
  });

  List<Habit> get filteredHabits {
    switch (filter) {
      case HabitsFilter.all:
        return habits;
      case HabitsFilter.pending:
        return habits.where((h) => !h.isCompletedToday).toList();
      case HabitsFilter.completed:
        return habits.where((h) => h.isCompletedToday).toList();
    }
  }

  int get completedTodayCount =>
      habits.where((h) => h.isCompletedToday).length;

  double get todayProgress {
    if (habits.isEmpty) return 0;
    return completedTodayCount / habits.length;
  }

  HabitsState copyWith({
    HabitsStatus? status,
    List<Habit>? habits,
    HabitsFilter? filter,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return HabitsState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      filter: filter ?? this.filter,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, habits, filter, errorMessage, infoMessage];
}
