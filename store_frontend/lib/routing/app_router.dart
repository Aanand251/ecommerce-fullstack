import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/presentation/screens/not_found_screen.dart';
import '../core/widgets/main_navigation_shell.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/cart/presentation/screens/checkout_screen.dart';
import '../features/orders/presentation/screens/order_details_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/payment/presentation/screens/payment_screen.dart';
import '../features/payment/presentation/screens/payment_success_screen.dart';
import '../features/products/presentation/screens/home_screen.dart';
import '../features/products/presentation/screens/product_details_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

/// Navigation shell key for preserving state
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider.
///
/// Provides clean, web-standard URLs with authentication redirection.
/// Uses Riverpod for reactive state management.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    debugLogDiagnostics: true,

    errorBuilder: (context, state) => const NotFoundScreen(),

    redirect: (context, state) {
      final authState = ref.watch(authProvider);
      final isAuthLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.loginPath || location == AppRoutes.registerPath;

      if (isAuthLoading && location != AppRoutes.splashPath) {
        return AppRoutes.splashPath;
      }

      if (location == AppRoutes.splashPath && !isAuthLoading) {
        return AppRoutes.homePath;
      }

      if (!isLoggedIn && !isPublicRoute(location)) {
        return AppRoutes.loginPath;
      }

      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.homePath;
      }

      return null; // No redirect
    },

    routes: [
      // Splash - no shell
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes - no shell
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app routes - with navigation shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.homePath,
            name: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.productsPath,
            name: AppRoutes.products,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.productDetailsPath,
            name: AppRoutes.productDetails,
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductDetailsScreen(productId: productId);
            },
          ),
          GoRoute(
            path: AppRoutes.cartPath,
            name: AppRoutes.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: AppRoutes.checkoutPath,
            name: AppRoutes.checkout,
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: AppRoutes.ordersPath,
            name: AppRoutes.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: AppRoutes.orderDetailsPath,
            name: AppRoutes.orderDetails,
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return OrderDetailsScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: AppRoutes.paymentPath,
            name: AppRoutes.payment,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return PaymentScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: AppRoutes.paymentSuccessPath,
            name: AppRoutes.paymentSuccess,
            builder: (context, state) => const PaymentSuccessScreen(),
          ),
          GoRoute(
            path: AppRoutes.profilePath,
            name: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Check if a route is public (accessible without authentication)
bool isPublicRoute(String location) {
  const publicRoutes = [
    AppRoutes.splashPath,
    AppRoutes.loginPath,
    AppRoutes.registerPath,
    AppRoutes.homePath,
    AppRoutes.productsPath,
  ];

  if (location.startsWith('/products/')) {
    return true;
  }

  return publicRoutes.contains(location);
}
