import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of auth state (null when logged out).
  Stream<UserEntity?> authStateChanges();

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, UserEntity>> reloadUser();

  Future<Either<Failure, void>> deleteAccount();
}
