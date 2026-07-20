part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final Auth auth;
  AuthAuthenticated({required this.auth});
}

final class AuthProfileCompleted extends AuthState {
  final Auth auth;
  AuthProfileCompleted({required this.auth});
}

final class AuthPendingVerification extends AuthState {
  final Auth auth;
  AuthPendingVerification({required this.auth});
}

final class AuthRejected extends AuthState {
  final Auth auth;
  final String reason;
  AuthRejected({required this.auth, required this.reason});
}

final class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure({required this.errorMessage});
}

final class AuthAccountDeleted extends AuthState {}
