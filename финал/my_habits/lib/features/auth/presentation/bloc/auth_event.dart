part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  const AuthResetPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthResendVerificationRequested extends AuthEvent {
  const AuthResendVerificationRequested();
}

class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}
