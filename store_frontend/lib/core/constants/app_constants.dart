/// Application-wide constants
///
/// Contains API endpoints, storage keys, and configuration values.
/// All constants are immutable and accessible throughout the app.

class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ─── API CONFIGURATION ─────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:8081/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  // Product endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';

  // Cart endpoints
  static const String cartEndpoint = '/cart';
  static const String addToCartEndpoint = '/cart/add';
  static const String removeFromCartEndpoint = '/cart/remove';
  static const String clearCartEndpoint = '/cart/clear';

  // Order endpoints
  static const String ordersEndpoint = '/orders';
  static const String placeOrderEndpoint = '/orders/place';
  static const String myOrdersEndpoint = '/orders/my';

  // Payment endpoints
  static const String paymentsEndpoint = '/payments';
  static const String createPaymentEndpoint = '/payments/create';
  static const String verifyPaymentEndpoint = '/payments/verify';

  // Admin endpoints
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminOrdersEndpoint = '/admin/orders';

  // ─── STORAGE KEYS ──────────────────────────────────────────────────
  static const String jwtTokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';

  // ─── UI CONFIGURATION ──────────────────────────────────────────────
  static const double maxContentWidth = 1200.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // ─── ANIMATION DURATIONS ───────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ─── RAZORPAY CONFIGURATION ────────────────────────────────────────
  static const String razorpayKeyId = 'rzp_test_SRtdBQxL8DjzHK';
}

/// Error messages displayed to users
class AppMessages {
  AppMessages._();

  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Something went wrong. Please try again.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
  static const String invalidCredentials = 'Invalid email or password';
  static const String registrationSuccess = 'Account created successfully!';
  static const String loginSuccess = 'Welcome back!';
  static const String logoutSuccess = 'Logged out successfully';
  static const String addedToCart = 'Added to cart';
  static const String removedFromCart = 'Removed from cart';
  static const String orderPlaced = 'Order placed successfully!';
  static const String paymentSuccess = 'Payment successful!';
  static const String paymentFailed = 'Payment failed. Please try again.';
}
