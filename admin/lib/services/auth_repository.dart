import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'debug_logger.dart';

part 'auth_repository.g.dart';

/// Repository for handling authentication logic using Supabase.
class AuthRepository {
  AuthRepository(this._supabase, this._logger);
  final SupabaseClient _supabase;
  final DebugLogger _logger;

  /// Signs in the user with email and password.
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e, st) {
      _logger.logError('Auth signIn failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e, st) {
      _logger.logError('Auth signOut failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Registers a new user with email, password, and additional profile metadata.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? organizationName,
  }) async {
    // TODO: [Security] Enable email confirmation requirement (OTP flow) in Supabase configuration for production based on PRD section 5.
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (organizationName != null) 'organization_name': organizationName,
        },
      );
    } catch (e, st) {
      _logger.logError('Auth signUp failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(Supabase.instance.client, ref.watch(debugLoggerProvider.notifier));
}
