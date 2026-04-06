import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';

/// Auth state - represents current authentication status.
///
/// States:
/// - `AsyncData(null)` - Not logged in
/// - `AsyncData(User)` - Logged in with user data
/// - `AsyncLoading()` - Loading (login/register in progress)
/// - `AsyncError` - Error during auth operation
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    ref.watch(sessionInvalidationProvider);

    // Check if user is already logged in on app startup
    return await _loadStoredUser();
  }

  /// Load user from SharedPreferences on app startup
  Future<User?> _loadStoredUser() async {
    try {
      final storage = ref.read(authStorageProvider);
      final token = await storage.getToken();
      final user = await storage.getUser();

      if (token != null && user != null) {

        AppLogger.info('Loaded stored user: ${user.email}');
        return user;
      }

      AppLogger.info('No stored user found');
      return null;
    } catch (e) {
      AppLogger.error('Error loading stored user', e);
      return null;
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);

      final request = LoginRequest(email: email, password: password);
      final authResponse = await repository.login(request);

      // Store token and user data
      await _storeAuthData(authResponse.token, authResponse.user);

      // Update state with logged-in user
      state = AsyncData(authResponse.user);

      AppLogger.info('Login successful: ${authResponse.user.email}');
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e, stackTrace);
      state = AsyncError(e, stackTrace);
      rethrow; // Re-throw to let UI handle the error
    }
  }

  /// Register new user
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);

      final request = RegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
      );
      final authResponse = await repository.register(request);

      // Store token and user data
      await _storeAuthData(authResponse.token, authResponse.user);

      // Update state with logged-in user
      state = AsyncData(authResponse.user);

      AppLogger.info('Registration successful: ${authResponse.user.email}');
    } catch (e, stackTrace) {
      AppLogger.error('Registration failed', e, stackTrace);
      state = AsyncError(e, stackTrace);
      rethrow; // Re-throw to let UI handle the error
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      final storage = ref.read(authStorageProvider);
      await storage.clearSession();

      // Update state to null (not logged in)
      state = const AsyncData(null);

      AppLogger.info('Logout successful');
    } catch (e, stackTrace) {
      AppLogger.error('Logout failed', e, stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }

  /// Store authentication data in SharedPreferences
  Future<void> _storeAuthData(String token, User user) async {
    try {
      final storage = ref.read(authStorageProvider);
      await storage.saveSession(token: token, user: user);

      AppLogger.debug('Auth data stored successfully');
    } catch (e) {
      AppLogger.error('Failed to store auth data', e);
      rethrow;
    }
  }

  Future<void> handleUnauthorized() async {
    final storage = ref.read(authStorageProvider);
    await storage.clearSession();
    state = const AsyncData(null);
  }

  /// Get current user (convenience getter)
  User? get currentUser => state.valueOrNull;

  /// Check if user is logged in
  bool get isLoggedIn => state.valueOrNull != null;

  /// Check if user is admin
  bool get isAdmin => state.valueOrNull?.isAdmin ?? false;
}

/// Auth state provider
///
/// Usage:
/// ```dart
/// // Watch auth state
/// final authState = ref.watch(authProvider);
///
/// // Login
/// await ref.read(authProvider.notifier).login(email, password);
///
/// // Register
/// await ref.read(authProvider.notifier).register(
///   fullName: name,
///   email: email,
///   password: password,
/// );
///
/// // Logout
/// await ref.read(authProvider.notifier).logout();
/// ```
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

/// Convenience provider for checking if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Convenience provider for getting current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

/// Convenience provider for checking if user is admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});
