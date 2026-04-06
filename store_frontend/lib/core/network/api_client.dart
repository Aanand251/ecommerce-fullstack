import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../session/session_controller.dart';
import '../storage/auth_storage.dart';
import '../utils/logger.dart';

/// Dio HTTP client provider.
///
/// Provides a configured Dio instance with:
/// - Base URL
/// - Timeout settings
/// - JWT interceptor
/// - Error handling interceptor
/// - Logging interceptor
final dioProvider = Provider<Dio>((ref) {
  final authStorage = ref.watch(authStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.add(
    JwtInterceptor(
      ref: ref,
      authStorage: authStorage,
    ),
  );
  dio.interceptors.add(ErrorInterceptor());
  dio.interceptors.add(LoggingInterceptor());

  return dio;
});

/// JWT Interceptor - Automatically adds Bearer token to requests.
///
/// Retrieves token from SharedPreferences and injects it into
/// Authorization header for authenticated endpoints.
class JwtInterceptor extends Interceptor {
  final Ref ref;
  final AuthStorage authStorage;

  JwtInterceptor({required this.ref, required this.authStorage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Get token from SharedPreferences
    try {
      final token = await authStorage.getToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('JWT token added to request: ${options.path}');
      } else {
        AppLogger.warning('No JWT token found for: ${options.path}');
      }
    } catch (e) {
      AppLogger.error('Error retrieving JWT token', e);
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token expired or invalid
    if (err.response?.statusCode == 401) {
      AppLogger.warning('401 Unauthorized - clearing session');
      await authStorage.clearSession();
      ref.read(sessionInvalidationProvider.notifier).invalidate();
    }

    handler.next(err);
  }

  /// Check if endpoint is public (doesn't require authentication)
  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/auth/login',
      '/auth/register',
      '/products',
      '/categories',
      '/products/search',
      '/products/category',
    ];

    return publicPaths.any((publicPath) => path.contains(publicPath));
  }
}

/// Error Interceptor - Handles API errors globally.
///
/// Provides consistent error handling and logging for all API calls.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(err.response?.statusCode);
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'Connection error. Please check your internet connection.';
        break;

      case DioExceptionType.unknown:
        errorMessage = 'An unexpected error occurred. Please try again.';
        break;

      default:
        errorMessage = 'Something went wrong. Please try again.';
    }

    AppLogger.error('API Error: $errorMessage', err);

    // Attach user-friendly message to the error
    err = err.copyWith(
      message: errorMessage,
    );

    handler.next(err);
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your data.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// Logging Interceptor - Logs all HTTP requests and responses.
///
/// Useful for debugging API calls in development.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      '🌐 API Request: ${options.method} ${options.path}\n'
      'Headers: ${options.headers}\n'
      'Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      '✅ API Response: ${response.statusCode} ${response.requestOptions.path}\n'
      'Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '❌ API Error: ${err.response?.statusCode} ${err.requestOptions.path}\n'
      'Message: ${err.message}\n'
      'Response: ${err.response?.data}',
    );
    handler.next(err);
  }
}

/// API Response wrapper for consistent error handling.
///
/// Usage:
/// ```dart
/// final result = await ApiClient.handleRequest(() => dio.get('/endpoint'));
/// result.when(
///   success: (data) => print(data),
///   failure: (message) => print(message),
/// );
/// ```
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResult.failure(this.error)
      : data = null,
        isSuccess = false;

  void when({
    required Function(T data) success,
    required Function(String error) failure,
  }) {
    if (isSuccess && data != null) {
      success(data as T);
    } else {
      failure(error ?? 'Unknown error occurred');
    }
  }
}

/// API Client helper for handling requests with try-catch.
class ApiClient {
  /// Handle API request with automatic error handling
  static Future<ApiResult<T>> handleRequest<T>(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      return ApiResult.success(response.data as T);
    } on DioException catch (e) {
      AppLogger.error('API request failed', e);
      return ApiResult.failure(e.message ?? 'Network error');
    } catch (e) {
      AppLogger.error('Unexpected error in API request', e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }
}
