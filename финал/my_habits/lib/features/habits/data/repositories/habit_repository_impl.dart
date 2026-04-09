import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habits_remote_datasource.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitsRemoteDataSource remote;
  HabitRepositoryImpl(this.remote);

  @override
  Stream<List<Habit>> watchHabits(String userId) =>
      remote.watchHabits(userId);

  @override
  Future<Either<Failure, List<Habit>>> getHabits(String userId) async {
    try {
      final habits = await remote.getHabits(userId);
      return Right(habits);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> createHabit(
      {required String userId, required Habit habit}) async {
    try {
      final model = HabitModel.fromEntity(habit);
      final created =
          await remote.createHabit(userId: userId, habit: model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateHabit(
      {required String userId, required Habit habit}) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await remote.updateHabit(userId: userId, habit: model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(
      {required String userId, required String habitId}) async {
    try {
      await remote.deleteHabit(userId: userId, habitId: habitId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCompletion({
    required String userId,
    required String habitId,
    required DateTime date,
  }) async {
    try {
      await remote.toggleCompletion(
          userId: userId, habitId: habitId, date: date);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
