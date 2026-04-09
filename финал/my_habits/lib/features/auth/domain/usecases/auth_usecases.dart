import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
      {required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.signOut();
}

class SendPasswordResetUseCase {
  final AuthRepository repository;
  SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) =>
      repository.sendPasswordResetEmail(email);
}

class SendEmailVerificationUseCase {
  final AuthRepository repository;
  SendEmailVerificationUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.sendEmailVerification();
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() => repository.getCurrentUser();
}

class ReloadUserUseCase {
  final AuthRepository repository;
  ReloadUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.reloadUser();
}

class DeleteAccountUseCase {
  final AuthRepository repository;
  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.deleteAccount();
}
