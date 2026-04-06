import 'package:equatable/equatable.dart';

/// User model matching backend User entity.
///
/// Represents an authenticated user with their profile information.
class User extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String role; // ROLE_USER or ROLE_ADMIN
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.createdAt,
  });

  /// Create User from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as int?) ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'ROLE_USER',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert User to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Check if user is admin
  bool get isAdmin => role == 'ROLE_ADMIN';

  /// Check if user is regular user
  bool get isUser => role == 'ROLE_USER';

  /// Get display role (without ROLE_ prefix)
  String get displayRole => role.replaceFirst('ROLE_', '');

  /// Copy with modifications
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, role, createdAt];

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email, role: $role)';
  }
}
