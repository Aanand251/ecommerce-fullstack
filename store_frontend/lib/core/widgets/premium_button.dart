import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium button styles for the app.
enum PremiumButtonVariant { primary, secondary, outline, ghost, danger }

/// A modern, animated button with multiple variants.
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = PremiumButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final PremiumButtonSize size;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

enum PremiumButtonSize { small, medium, large }

class _PremiumButtonState extends State<PremiumButton> {
  bool _hovered = false;
  bool _pressed = false;

  EdgeInsets get _padding {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case PremiumButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case PremiumButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 13;
      case PremiumButtonSize.medium:
        return 14;
      case PremiumButtonSize.large:
        return 16;
    }
  }

  Color get _backgroundColor {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    switch (widget.variant) {
      case PremiumButtonVariant.primary:
        if (isDisabled) return AppColors.disabled;
        if (_pressed) return AppColors.primaryDark;
        if (_hovered) return AppColors.primaryLight;
        return AppColors.primary;
      case PremiumButtonVariant.secondary:
        if (isDisabled) return AppColors.disabled.withValues(alpha: 0.3);
        if (_pressed) return AppColors.accent.withValues(alpha: 0.9);
        if (_hovered) return AppColors.accent.withValues(alpha: 0.85);
        return AppColors.accent;
      case PremiumButtonVariant.outline:
      case PremiumButtonVariant.ghost:
        if (_pressed) return AppColors.primary.withValues(alpha: 0.08);
        if (_hovered) return AppColors.primary.withValues(alpha: 0.04);
        return Colors.transparent;
      case PremiumButtonVariant.danger:
        if (isDisabled) return AppColors.disabled;
        if (_pressed) return AppColors.error.withValues(alpha: 0.9);
        if (_hovered) return AppColors.error.withValues(alpha: 0.85);
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    switch (widget.variant) {
      case PremiumButtonVariant.primary:
      case PremiumButtonVariant.secondary:
      case PremiumButtonVariant.danger:
        return isDisabled ? AppColors.textTertiary : AppColors.textOnPrimary;
      case PremiumButtonVariant.outline:
      case PremiumButtonVariant.ghost:
        return isDisabled ? AppColors.disabled : AppColors.primary;
    }
  }

  Border? get _border {
    if (widget.variant == PremiumButtonVariant.outline) {
      final isDisabled = widget.onPressed == null || widget.isLoading;
      return Border.all(
        color: isDisabled ? AppColors.disabled : AppColors.primary,
        width: 1.5,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: widget.isFullWidth ? double.infinity : null,
          padding: _padding,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: _border,
            boxShadow: widget.variant == PremiumButtonVariant.primary && !isDisabled && _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: _foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: _foregroundColor,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon-only premium button for compact actions.
class PremiumIconButton extends StatefulWidget {
  const PremiumIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = PremiumButtonVariant.ghost,
    this.size = 40,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final PremiumButtonVariant variant;
  final double size;
  final int? badgeCount;

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    Color bgColor = Colors.transparent;
    Color iconColor = AppColors.textPrimary;

    if (widget.variant == PremiumButtonVariant.primary) {
      bgColor = isDisabled ? AppColors.disabled : (_hovered ? AppColors.primaryLight : AppColors.primary);
      iconColor = AppColors.textOnPrimary;
    } else {
      if (_hovered && !isDisabled) {
        bgColor = AppColors.primary.withValues(alpha: 0.06);
      }
      iconColor = isDisabled ? AppColors.disabled : AppColors.textPrimary;
    }

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(widget.icon, size: 22, color: iconColor)),
              if (widget.badgeCount != null && widget.badgeCount! > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      widget.badgeCount! > 99 ? '99+' : '${widget.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
