import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit.dart';

abstract class HabitRepository {
  /// Stream of user's habits (realtime updates from Firestore).
  Stream<List<Habit>> watchHabits(String userId);

  Future<Either<Failure, List<Habit>>> getHabits(String userId);

  Future<Either<Failure, Habit>> createHabit(
      {required String userId, required Habit habit});

  Future<Either<Failure, void>> updateHabit(
      {required String userId, required Habit habit});

  Future<Either<Failure, void>> deleteHabit(
      {required String userId, required String habitId});

  Future<Either<Failure, void>> toggleCompletion(
      {required String userId,
      required String habitId,
      required DateTime date});
}
