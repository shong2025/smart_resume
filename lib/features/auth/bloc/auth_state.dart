abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {
  final String? message;
  AuthUnauthenticated({this.message});
}

class AuthEmailUnconfirmed extends AuthState {
  final String email;
  AuthEmailUnconfirmed(this.email);
}
