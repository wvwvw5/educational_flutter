import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/habit_usecases.dart';

part 'habits_event.dart';
part 'habits_state.dart';

class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  final WatchHabitsUseCase watchHabits;
  final CreateHabitUseCase createHabit;
  final UpdateHabitUseCase updateHabit;
  final DeleteHabitUseCase deleteHabit;
  final ToggleHabitCompletionUseCase toggleCompletion;
  final NotificationService notifications;

  String? _userId;
  StreamSubscription<List<Habit>>? _habitsSub;

  HabitsBloc({
    required this.watchHabits,
    required this.createHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.toggleCompletion,
    required this.notifications,
  }) : super(const HabitsState()) {
    on<HabitsSubscriptionRequested>(_onSubscribe);
    on<HabitsUpdated>(_onHabitsUpdated);
    on<HabitsErrorOccurred>(_onError);
    on<HabitCreated>(_onCreate);
    on<HabitUpdated>(_onUpdate);
    on<HabitDeleted>(_onDelete);
    on<HabitCompletionToggled>(_onToggle);
    on<HabitsFilterChanged>(_onFilterChanged);
    on<HabitsCleared>(_onClear);
  }

  Future<void> _onSubscribe(
      HabitsSubscriptionRequested event, Emitter<HabitsState> emit) async {
    _userId = event.userId;
    emit(state.copyWith(status: HabitsStatus.loading, clearMessages: true));
    await _habitsSub?.cancel();
    _habitsSub = watchHabits(event.userId).listen(
      (habits) => add(HabitsUpdated(habits)),
      onError: (e) => add(HabitsErrorOccurred(e.toString())),
    );
  }

  void _onHabitsUpdated(HabitsUpdated event, Emitter<HabitsState> emit) {
    emit(state.copyWith(
      status: HabitsStatus.loaded,
      habits: event.habits,
      clearMessages: true,
    ));
    _resyncNotifications(event.habits);
  }

  void _onError(HabitsErrorOccurred event, Emitter<HabitsState> emit) {
    emit(state.copyWith(
      status: HabitsStatus.error,
      errorMessage: event.message,
    ));
  }

  Future<void> _onCreate(
      HabitCreated event, Emitter<HabitsState> emit) async {
    if (_userId == null) return;
    final result =
        await createHabit(userId: _userId!, habit: event.habit);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (created) {
        emit(state.copyWith(infoMessage: 'Привычка создана'));
        if (created.reminderEnabled) {
          notifications.scheduleDailyReminder(
            id: created.notificationId,
            title: 'Время для привычки',
            body: created.title,
            hour: created.reminderHour,
            minute: created.reminderMinute,
          );
        }
      },
    );
  }

  Future<void> _onUpdate(
      HabitUpdated event, Emitter<HabitsState> emit) async {
    if (_userId == null) return;
    final result =
        await updateHabit(userId: _userId!, habit: event.habit);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {
        emit(state.copyWith(infoMessage: 'Привычка обновлена'));
        notifications.cancel(event.habit.notificationId);
        if (event.habit.reminderEnabled) {
          notifications.scheduleDailyReminder(
            id: event.habit.notificationId,
            title: 'Время для привычки',
            body: event.habit.title,
            hour: event.habit.reminderHour,
            minute: event.habit.reminderMinute,
          );
        }
      },
    );
  }

  Future<void> _onDelete(
      HabitDeleted event, Emitter<HabitsState> emit) async {
    if (_userId == null) return;
    final habit = state.habits.firstWhere(
      (h) => h.id == event.habitId,
      orElse: () => Habit(
        id: event.habitId,
        title: '',
        colorValue: 0,
        iconCodePoint: 0,
        reminderHour: 0,
        reminderMinute: 0,
        reminderEnabled: false,
        createdAt: DateTime.now(),
        completedDates: const [],
      ),
    );
    final result =
        await deleteHabit(userId: _userId!, habitId: event.habitId);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {
        notifications.cancel(habit.notificationId);
        emit(state.copyWith(infoMessage: 'Привычка удалена'));
      },
    );
  }

  Future<void> _onToggle(
      HabitCompletionToggled event, Emitter<HabitsState> emit) async {
    if (_userId == null) return;
    final result = await toggleCompletion(
      userId: _userId!,
      habitId: event.habitId,
      date: event.date,
    );
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {},
    );
  }

  void _onFilterChanged(
      HabitsFilterChanged event, Emitter<HabitsState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onClear(
      HabitsCleared event, Emitter<HabitsState> emit) async {
    await _habitsSub?.cancel();
    _userId = null;
    await notifications.cancelAll();
    emit(const HabitsState());
  }

  void _resyncNotifications(List<Habit> habits) {
    for (final habit in habits) {
      if (habit.reminderEnabled) {
        notifications.scheduleDailyReminder(
          id: habit.notificationId,
          title: 'Время для привычки',
          body: habit.title,
          hour: habit.reminderHour,
          minute: habit.reminderMinute,
        );
      } else {
        notifications.cancel(habit.notificationId);
      }
    }
  }

  @override
  Future<void> close() {
    _habitsSub?.cancel();
    return super.close();
  }
}
