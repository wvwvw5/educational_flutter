import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/habits/data/datasources/habits_remote_datasource.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/habit_usecases.dart';
import '../../features/habits/presentation/bloc/habits_bloc.dart';

import '../notifications/notification_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // Services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // === AUTH ===
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt()));

  getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton(() => SendPasswordResetUseCase(getIt()));
  getIt.registerLazySingleton(() => SendEmailVerificationUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => ReloadUserUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteAccountUseCase(getIt()));

  getIt.registerFactory(() => AuthBloc(
        authRepository: getIt(),
        signIn: getIt(),
        signUp: getIt(),
        signOut: getIt(),
        sendPasswordReset: getIt(),
        sendEmailVerification: getIt(),
        reloadUser: getIt(),
        deleteAccount: getIt(),
      ));

  // === HABITS ===
  getIt.registerLazySingleton<HabitsRemoteDataSource>(
      () => HabitsRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<HabitRepository>(
      () => HabitRepositoryImpl(getIt()));

  getIt.registerLazySingleton(() => WatchHabitsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetHabitsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => ToggleHabitCompletionUseCase(getIt()));

  getIt.registerFactory(() => HabitsBloc(
        watchHabits: getIt(),
        createHabit: getIt(),
        updateHabit: getIt(),
        deleteHabit: getIt(),
        toggleCompletion: getIt(),
        notifications: getIt(),
      ));
}
