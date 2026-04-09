part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticatedUnverified,
  authenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, user, isLoading, errorMessage, infoMessage];
}
