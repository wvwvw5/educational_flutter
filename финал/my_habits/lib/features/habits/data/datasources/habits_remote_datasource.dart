import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/habit_model.dart';

abstract class HabitsRemoteDataSource {
  Stream<List<HabitModel>> watchHabits(String userId);
  Future<List<HabitModel>> getHabits(String userId);
  Future<HabitModel> createHabit(
      {required String userId, required HabitModel habit});
  Future<void> updateHabit(
      {required String userId, required HabitModel habit});
  Future<void> deleteHabit(
      {required String userId, required String habitId});
  Future<void> toggleCompletion({
    required String userId,
    required String habitId,
    required DateTime date,
  });
}

class HabitsRemoteDataSourceImpl implements HabitsRemoteDataSource {
  final FirebaseFirestore firestore;
  HabitsRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      firestore.collection('users').doc(userId).collection('habits');

  @override
  Stream<List<HabitModel>> watchHabits(String userId) {
    return _col(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => HabitModel.fromFirestore(d)).toList());
  }

  @override
  Future<List<HabitModel>> getHabits(String userId) async {
    try {
      final snap = await _col(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => HabitModel.fromFirestore(d)).toList();
    } catch (e) {
      throw ServerException('Не удалось загрузить привычки');
    }
  }

  @override
  Future<HabitModel> createHabit(
      {required String userId, required HabitModel habit}) async {
    try {
      final ref = await _col(userId).add(habit.toFirestore());
      final snap = await ref.get();
      return HabitModel.fromFirestore(snap);
    } catch (e) {
      throw ServerException('Не удалось создать привычку');
    }
  }

  @override
  Future<void> updateHabit(
      {required String userId, required HabitModel habit}) async {
    try {
      await _col(userId).doc(habit.id).update(habit.toFirestore());
    } catch (e) {
      throw ServerException('Не удалось обновить привычку');
    }
  }

  @override
  Future<void> deleteHabit(
      {required String userId, required String habitId}) async {
    try {
      await _col(userId).doc(habitId).delete();
    } catch (e) {
      throw ServerException('Не удалось удалить привычку');
    }
  }

  @override
  Future<void> toggleCompletion({
    required String userId,
    required String habitId,
    required DateTime date,
  }) async {
    try {
      final doc = _col(userId).doc(habitId);
      final snap = await doc.get();
      if (!snap.exists) {
        throw ServerException('Привычка не найдена');
      }
      final habit = HabitModel.fromFirestore(snap);
      final day = DateTime(date.year, date.month, date.day);
      final existingIndex = habit.completedDates.indexWhere((d) {
        final normalized = DateTime(d.year, d.month, d.day);
        return normalized == day;
      });
      final newList = List<DateTime>.from(habit.completedDates);
      if (existingIndex >= 0) {
        newList.removeAt(existingIndex);
      } else {
        newList.add(day);
      }
      await doc.update({
        'completedDates':
            newList.map((d) => Timestamp.fromDate(d)).toList(),
      });
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Не удалось отметить выполнение');
    }
  }
}
