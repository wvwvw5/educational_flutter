import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> authStateChanges();
  Future<UserModel> signIn(
      {required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> reloadUser();
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  AuthRemoteDataSourceImpl(this.firebaseAuth);

  @override
  Stream<UserModel?> authStateChanges() {
    return firebaseAuth.authStateChanges().map(
          (user) => user == null ? null : UserModel.fromFirebase(user),
        );
  }

  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthException('Не удалось получить данные пользователя');
      }
      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (_) {
      throw AuthException('Не удалось войти. Проверьте соединение');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthException('Не удалось создать аккаунт');
      }
      await user.updateDisplayName(displayName);
      await user.sendEmailVerification();
      await user.reload();
      final refreshed = firebaseAuth.currentUser!;
      return UserModel.fromFirebase(refreshed);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (_) {
      throw AuthException('Не удалось зарегистрироваться');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (_) {
      throw AuthException('Не удалось выйти из аккаунта');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (_) {
      throw AuthException('Не удалось отправить письмо для сброса пароля');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('Пользователь не авторизован');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (_) {
      throw AuthException('Не удалось отправить письмо подтверждения');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebase(user);
  }

  @override
  Future<UserModel> reloadUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('Пользователь не авторизован');
      }
      await user.reload();
      final refreshed = firebaseAuth.currentUser!;
      return UserModel.fromFirebase(refreshed);
    } catch (_) {
      throw AuthException('Не удалось обновить данные пользователя');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('Пользователь не авторизован');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (_) {
      throw AuthException('Не удалось удалить аккаунт');
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Нет подключения к интернету';
      case 'requires-recent-login':
        return 'Требуется повторный вход для выполнения операции';
      default:
        return e.message ?? 'Ошибка авторизации';
    }
  }
}
