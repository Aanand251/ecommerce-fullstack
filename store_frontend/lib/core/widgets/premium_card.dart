import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A premium card component with hover effects.
class PremiumCard extends StatefulWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.elevation = 1,
    this.hoverElevation = 2,
    this.showBorder = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final int elevation;
  final int hoverElevation;
  final bool showBorder;

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _hovered = false;

  List<BoxShadow> get _shadow {
    final targetElevation = _hovered ? widget.hoverElevation : widget.elevation;
    switch (targetElevation) {
      case 0:
        return [];
      case 1:
        return AppColors.cardShadow;
      case 2:
        return AppColors.elevatedShadow;
      default:
        return AppColors.hoverShadow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.showBorder
                  ? Border.all(
                      color: _hovered ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
                    )
                  : null,
              boxShadow: _shadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A premium section header.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

/// Quantity selector for cart items.
class QuantitySelector extends StatefulWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.size = QuantitySelectorSize.medium,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final QuantitySelectorSize size;

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

enum QuantitySelectorSize { small, medium }

class _QuantitySelectorState extends State<QuantitySelector> {
  double get _buttonSize {
    switch (widget.size) {
      case QuantitySelectorSize.small:
        return 28;
      case QuantitySelectorSize.medium:
        return 36;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case QuantitySelectorSize.small:
        return 13;
      case QuantitySelectorSize.medium:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrease = widget.quantity > widget.min;
    final canIncrease = widget.quantity < widget.max;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            size: _buttonSize,
            enabled: canDecrease,
            onTap: canDecrease ? () => widget.onChanged(widget.quantity - 1) : null,
          ),
          Container(
            constraints: BoxConstraints(minWidth: _buttonSize),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${widget.quantity}',
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            size: _buttonSize,
            enabled: canIncrease,
            onTap: canIncrease ? () => widget.onChanged(widget.quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatefulWidget {
  const _QuantityButton({
    required this.icon,
    required this.size,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.enabled && _hovered
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
          ),
        ),
      ),
    );
  }
}

/// Avatar component.
class PremiumAvatar extends StatelessWidget {
  const PremiumAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 44,
    this.showBorder = false,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBorder;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: AppColors.border, width: 2) : null,
        gradient: imageUrl == null ? AppColors.primaryGradient : null,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                _initials,
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.38,
                ),
              ),
            )
          : null,
    );
  }
}

/// Divider with optional label.
class PremiumDivider extends StatelessWidget {
  const PremiumDivider({
    super.key,
    this.label,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  final String? label;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: padding,
        child: const Divider(color: AppColors.divider, height: 1),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label!,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        ],
      ),
    );
  }
}
