/// Route path constants for GoRouter.
///
/// Centralized route definitions for maintainability.
/// Use these constants throughout the app for navigation.
class AppRoutes {
  AppRoutes._();

  // ─── ROUTE NAMES ───────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String products = 'products';
  static const String productDetails = 'product-details';
  static const String categories = 'categories';
  static const String categoryProducts = 'category-products';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String orders = 'orders';
  static const String orderDetails = 'order-details';
  static const String payment = 'payment';
  static const String paymentSuccess = 'payment-success';
  static const String profile = 'profile';

  // Admin routes
  static const String adminDashboard = 'admin-dashboard';
  static const String adminUsers = 'admin-users';
  static const String adminOrders = 'admin-orders';
  static const String adminProducts = 'admin-products';

  // ─── ROUTE PATHS ───────────────────────────────────────────────────
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/';
  static const String productsPath = '/products';
  static const String productDetailsPath = '/products/:id';
  static const String categoriesPath = '/categories';
  static const String categoryProductsPath = '/categories/:id/products';
  static const String cartPath = '/cart';
  static const String checkoutPath = '/checkout';
  static const String ordersPath = '/orders';
  static const String orderDetailsPath = '/orders/:id';
  static const String paymentPath = '/payment/:orderId';
  static const String paymentSuccessPath = '/payment-success';
  static const String profilePath = '/profile';

  // Admin paths
  static const String adminDashboardPath = '/admin';
  static const String adminUsersPath = '/admin/users';
  static const String adminOrdersPath = '/admin/orders';
  static const String adminProductsPath = '/admin/products';

  // ─── HELPER METHODS ────────────────────────────────────────────────
  /// Generate product details path with ID
  static String productDetailsWithId(String id) => '/products/$id';

  /// Generate category products path with ID
  static String categoryProductsWithId(String id) => '/categories/$id/products';

  /// Generate order details path with ID
  static String orderDetailsWithId(String id) => '/orders/$id';

  /// Generate payment path with order ID
  static String paymentWithOrderId(String orderId) => '/payment/$orderId';
}
