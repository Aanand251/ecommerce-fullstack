import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension methods for common operations.
///
/// Provides convenient shortcuts for formatting, navigation, and UI.

// ─── CONTEXT EXTENSIONS ──────────────────────────────────────────────

extension ContextExtensions on BuildContext {
  /// Get ThemeData
  ThemeData get theme => Theme.of(this);

  /// Get TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get MediaQueryData
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ─── STRING EXTENSIONS ───────────────────────────────────────────────

extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{10,13}$').hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// ─── NUMBER EXTENSIONS ───────────────────────────────────────────────

extension NumberExtensions on num {
  /// Format as Indian currency (₹)
  String get toRupees {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  /// Format as compact currency (e.g., ₹1.2K)
  String get toCompactRupees {
    final formatter = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 1,
    );
    return formatter.format(this);
  }

  /// Format with commas
  String get withCommas {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(this);
  }

  /// Format as percentage
  String get toPercentage {
    return '${(this * 100).toStringAsFixed(0)}%';
  }
}

// ─── DATETIME EXTENSIONS ─────────────────────────────────────────────

extension DateTimeExtensions on DateTime {
  /// Format as "dd MMM yyyy" (e.g., "25 Mar 2026")
  String get formatted {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// Format as "dd MMM yyyy, hh:mm a" (e.g., "25 Mar 2026, 03:45 PM")
  String get formattedWithTime {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  /// Format as relative time (e.g., "2 hours ago", "Yesterday")
  String get relative {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    }
    return '${(difference.inDays / 365).floor()} years ago';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

// ─── WIDGET EXTENSIONS ───────────────────────────────────────────────

extension WidgetExtensions on Widget {
  /// Wrap with Padding
  Widget withPadding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// Wrap with Center
  Widget centered() {
    return Center(child: this);
  }

  /// Wrap with Expanded
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  /// Wrap with Opacity
  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Wrap with GestureDetector
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// Wrap with InkWell
  Widget onTapInk(VoidCallback onTap, {BorderRadius? borderRadius}) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: this,
    );
  }
}
