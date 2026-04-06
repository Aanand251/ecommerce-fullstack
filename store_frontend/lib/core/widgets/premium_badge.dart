import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Badge variants for different contexts.
enum BadgeVariant { success, warning, error, info, neutral, accent }

/// A modern badge/chip component.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
    this.onTap,
    this.size = BadgeSize.medium,
  });

  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final VoidCallback? onTap;
  final BadgeSize size;

  Color get _backgroundColor {
    switch (variant) {
      case BadgeVariant.success:
        return AppColors.success.withValues(alpha: 0.1);
      case BadgeVariant.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case BadgeVariant.error:
        return AppColors.error.withValues(alpha: 0.1);
      case BadgeVariant.info:
        return AppColors.primary.withValues(alpha: 0.08);
      case BadgeVariant.accent:
        return AppColors.accent.withValues(alpha: 0.15);
      case BadgeVariant.neutral:
        return AppColors.textSecondary.withValues(alpha: 0.08);
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case BadgeVariant.success:
        return AppColors.success;
      case BadgeVariant.warning:
        return const Color(0xFFB8860B); // Darker amber for readability
      case BadgeVariant.error:
        return AppColors.error;
      case BadgeVariant.info:
        return AppColors.primary;
      case BadgeVariant.accent:
        return const Color(0xFF8B6914); // Darker gold
      case BadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double get _fontSize {
    switch (size) {
      case BadgeSize.small:
        return 11;
      case BadgeSize.medium:
        return 12;
      case BadgeSize.large:
        return 14;
    }
  }

  double get _iconSize {
    switch (size) {
      case BadgeSize.small:
        return 12;
      case BadgeSize.medium:
        return 14;
      case BadgeSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: _iconSize, color: _foregroundColor),
            SizedBox(width: size == BadgeSize.small ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: _foregroundColor,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: badge,
        ),
      );
    }
    return badge;
  }
}

enum BadgeSize { small, medium, large }

/// A dot indicator for status.
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    this.variant = BadgeVariant.neutral,
    this.size = 8,
    this.pulsing = false,
  });

  final BadgeVariant variant;
  final double size;
  final bool pulsing;

  Color get _color {
    switch (variant) {
      case BadgeVariant.success:
        return AppColors.success;
      case BadgeVariant.warning:
        return AppColors.warning;
      case BadgeVariant.error:
        return AppColors.error;
      case BadgeVariant.info:
        return AppColors.primary;
      case BadgeVariant.accent:
        return AppColors.accent;
      case BadgeVariant.neutral:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
      ),
    );

    if (pulsing) {
      return _PulsingDot(color: _color, size: size);
    }
    return dot;
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _animation.value),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Category chip with selection state.
class CategoryChip extends StatefulWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : _hovered
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : _hovered
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
