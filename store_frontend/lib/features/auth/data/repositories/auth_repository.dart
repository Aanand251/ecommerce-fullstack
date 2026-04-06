import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/models.dart';

/// Auth repository provider.
///
/// Provides access to authentication-related API calls.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

/// Repository for authentication operations.
///
/// Handles all auth-related API calls:
/// - Login
/// - Register
/// - Logout (token removal)
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login user with email and password.
  ///
  /// POST /api/auth/login
  ///
  /// Returns [AuthResponse] with JWT token and user data on success.
  /// Throws [DioException] on failure.
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      AppLogger.info('Attempting login for: ${request.email}');

      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      AppLogger.info('Login successful for: ${request.email}');

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Login failed', e);

      // Extract error message from backend response
      String errorMessage = 'Login failed';

      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map<String, dynamic>;
        errorMessage = data['message'] as String? ??
            data['error'] as String? ??
            'Invalid email or password';
      }

      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: errorMessage,
      );
    } catch (e) {
      AppLogger.error('Unexpected error during login', e);
      rethrow;
    }
  }

  /// Register new user.
  ///
  /// POST /api/auth/register
  ///
  /// Returns [AuthResponse] with JWT token and user data on success.
  /// Throws [DioException] on failure (e.g., email already exists).
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      AppLogger.info('Attempting registration for: ${request.email}');

      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: request.toJson(),
      );

      AppLogger.info('Registration successful for: ${request.email}');

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Registration failed', e);

      // Extract error message from backend response
      String errorMessage = 'Registration failed';

      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map<String, dynamic>;
        errorMessage = data['message'] as String? ??
            data['error'] as String? ??
            'Email already exists or invalid data';
      }

      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: errorMessage,
      );
    } catch (e) {
      AppLogger.error('Unexpected error during registration', e);
      rethrow;
    }
  }

  /// Get current user profile.
  ///
  /// This can be called after login to refresh user data.
  /// Note: Requires valid JWT token in SharedPreferences.
  Future<User> getCurrentUser() async {
    try {
      // Assuming backend has a /api/auth/me endpoint
      // If not, we can retrieve user from stored data
      final response = await _dio.get('/auth/me');

      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      rethrow;
    }
  }
}
