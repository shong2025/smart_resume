import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient client = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<RegisterRequested>(_register);
    on<LogoutRequested>(_logout);
    on<ResendConfirmationEmailRequested>(_resendConfirmation);
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await client.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          emit(AuthEmailUnconfirmed(event.email));
        } else {
          emit(AuthAuthenticated());
        }
      } else {
        emit(AuthUnauthenticated(message: "Invalid email or password"));
      }
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _register(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await client.auth.signUp(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          emit(AuthEmailUnconfirmed(event.email));
        } else {
          emit(AuthAuthenticated());
        }
      } else {
        emit(AuthUnauthenticated(message: "Registration failed"));
      }
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    await client.auth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _resendConfirmation(
      ResendConfirmationEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: event.email,
      );
      emit(AuthEmailUnconfirmed(event.email));
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }
}
