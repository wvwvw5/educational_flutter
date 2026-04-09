import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class WatchHabitsUseCase {
  final HabitRepository repository;
  WatchHabitsUseCase(this.repository);

  Stream<List<Habit>> call(String userId) => repository.watchHabits(userId);
}

class GetHabitsUseCase {
  final HabitRepository repository;
  GetHabitsUseCase(this.repository);

  Future<Either<Failure, List<Habit>>> call(String userId) =>
      repository.getHabits(userId);
}

class CreateHabitUseCase {
  final HabitRepository repository;
  CreateHabitUseCase(this.repository);

  Future<Either<Failure, Habit>> call(
          {required String userId, required Habit habit}) =>
      repository.createHabit(userId: userId, habit: habit);
}

class UpdateHabitUseCase {
  final HabitRepository repository;
  UpdateHabitUseCase(this.repository);

  Future<Either<Failure, void>> call(
          {required String userId, required Habit habit}) =>
      repository.updateHabit(userId: userId, habit: habit);
}

class DeleteHabitUseCase {
  final HabitRepository repository;
  DeleteHabitUseCase(this.repository);

  Future<Either<Failure, void>> call(
          {required String userId, required String habitId}) =>
      repository.deleteHabit(userId: userId, habitId: habitId);
}

class ToggleHabitCompletionUseCase {
  final HabitRepository repository;
  ToggleHabitCompletionUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String habitId,
    required DateTime date,
  }) =>
      repository.toggleCompletion(
        userId: userId,
        habitId: habitId,
        date: date,
      );
}
