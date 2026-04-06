import 'user_model.dart';

/// Auth response DTO matching backend AuthResponse.
///
/// Received from POST /api/auth/login and POST /api/auth/register
class AuthResponse {
  final String token;
  final String email;
  final String role;
  final String fullName;
  final String tokenType;

  const AuthResponse({
    required this.token,
    required this.email,
    required this.role,
    required this.fullName,
    required this.tokenType,
  });

  User get user => User(
        id: 0,
        fullName: fullName,
        email: email,
        role: role,
      );

  /// Create AuthResponse from JSON (API response)
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  /// Convert to JSON (for storage if needed)
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'role': role,
      'fullName': fullName,
      'tokenType': tokenType,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(token: ${token.substring(0, 20)}..., email: $email, role: $role)';
  }
}
