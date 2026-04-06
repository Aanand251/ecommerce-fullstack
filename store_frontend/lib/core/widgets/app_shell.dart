import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/app_constants.dart';
import '../theme/theme.dart';

/// Shared enterprise shell for pages.
///
/// Keeps all screens visually consistent with:
/// - constrained max width on large monitors
/// - clean premium app bar
/// - responsive horizontal spacing
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.padding,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final EdgeInsets? padding;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;
    final horizontalPadding = width < AppConstants.mobileBreakpoint
        ? 16.0
        : width < AppConstants.tabletBreakpoint
            ? 24.0
            : 32.0;

    return Scaffold(
      appBar: _buildAppBar(context, isDesktop),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
            child: child,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, bool isDesktop) {
    // On desktop with navigation shell, use minimal header
    if (isDesktop) {
      return AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                icon: const Icon(Iconsax.arrow_left, size: 22),
                tooltip: 'Back',
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: actions != null
            ? [
                ...actions!,
                const SizedBox(width: 8),
              ]
            : null,
      );
    }

    // Mobile app bar with back button support
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: AppColors.surface,
      leading: showBackButton
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(Iconsax.arrow_left, size: 22),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 4),
            ]
          : null,
    );
  }
}
