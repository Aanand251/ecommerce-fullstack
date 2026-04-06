import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/theme.dart';
import 'routing/routing.dart';

/// Application entry point.
///
/// Initializes Riverpod for state management and GoRouter for navigation.
/// Applies professional theme with Inter font family.
void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure GoogleFonts is licensed properly
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(
      child: StoreApp(),
    ),
  );
}

/// Root application widget.
///
/// Sets up theming, routing, and global configurations.
class StoreApp extends ConsumerWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Premium Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
      ),
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
