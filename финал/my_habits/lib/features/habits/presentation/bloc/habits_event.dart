part of 'habits_bloc.dart';

abstract class HabitsEvent extends Equatable {
  const HabitsEvent();
  @override
  List<Object?> get props => [];
}

class HabitsSubscriptionRequested extends HabitsEvent {
  final String userId;
  const HabitsSubscriptionRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class HabitsUpdated extends HabitsEvent {
  final List<Habit> habits;
  const HabitsUpdated(this.habits);
  @override
  List<Object?> get props => [habits];
}

class HabitsErrorOccurred extends HabitsEvent {
  final String message;
  const HabitsErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

class HabitCreated extends HabitsEvent {
  final Habit habit;
  const HabitCreated(this.habit);
  @override
  List<Object?> get props => [habit];
}

class HabitUpdated extends HabitsEvent {
  final Habit habit;
  const HabitUpdated(this.habit);
  @override
  List<Object?> get props => [habit];
}

class HabitDeleted extends HabitsEvent {
  final String habitId;
  const HabitDeleted(this.habitId);
  @override
  List<Object?> get props => [habitId];
}

class HabitCompletionToggled extends HabitsEvent {
  final String habitId;
  final DateTime date;
  const HabitCompletionToggled({required this.habitId, required this.date});
  @override
  List<Object?> get props => [habitId, date];
}

class HabitsFilterChanged extends HabitsEvent {
  final HabitsFilter filter;
  const HabitsFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class HabitsCleared extends HabitsEvent {
  const HabitsCleared();
}
