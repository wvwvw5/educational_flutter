import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final SendPasswordResetUseCase sendPasswordReset;
  final SendEmailVerificationUseCase sendEmailVerification;
  final ReloadUserUseCase reloadUser;
  final DeleteAccountUseCase deleteAccount;

  StreamSubscription<UserEntity?>? _userSub;

  AuthBloc({
    required this.authRepository,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.sendPasswordReset,
    required this.sendEmailVerification,
    required this.reloadUser,
    required this.deleteAccount,
  }) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthResendVerificationRequested>(_onResendVerification);
    on<AuthRefreshRequested>(_onRefresh);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
  }

  Future<void> _onStarted(
      AuthStarted event, Emitter<AuthState> emit) async {
    _userSub?.cancel();
    _userSub = authRepository.authStateChanges().listen(
          (user) => add(AuthUserChanged(user)),
          onError: (_) => add(const AuthUserChanged(null)),
        );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user == null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        clearMessages: true,
      ));
    } else if (!user.emailVerified) {
      emit(state.copyWith(
        status: AuthStatus.authenticatedUnverified,
        user: user,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    }
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result =
        await signIn(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await signUp(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        isLoading: false,
        infoMessage:
            'Письмо со ссылкой подтверждения отправлено на вашу почту',
      )),
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await signOut();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> _onResetPassword(
      AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await sendPasswordReset(event.email);
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        isLoading: false,
        infoMessage: 'Письмо для сброса пароля отправлено',
      )),
    );
  }

  Future<void> _onResendVerification(
      AuthResendVerificationRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await sendEmailVerification();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        isLoading: false,
        infoMessage: 'Письмо подтверждения отправлено повторно',
      )),
    );
  }

  Future<void> _onRefresh(
      AuthRefreshRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await reloadUser();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (user) {
        if (user.emailVerified) {
          emit(state.copyWith(
            isLoading: false,
            status: AuthStatus.authenticated,
            user: user,
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            status: AuthStatus.authenticatedUnverified,
            user: user,
            infoMessage: 'Email ещё не подтверждён',
          ));
        }
      },
    );
  }

  Future<void> _onDeleteAccount(
      AuthDeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await deleteAccount();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
