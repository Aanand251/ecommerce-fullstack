/// Login request DTO matching backend LoginRequest.
///
/// Sent to POST /api/auth/login
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() => 'LoginRequest(email: $email)';
}

/// Register request DTO matching backend RegisterRequest.
///
/// Sent to POST /api/auth/register
class RegisterRequest {
  final String fullName;
  final String email;
  final String password;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() => 'RegisterRequest(fullName: $fullName, email: $email)';
}
