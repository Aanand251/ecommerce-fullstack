# Premium E-Commerce Store - Flutter Web Frontend

A professional, enterprise-grade e-commerce web application built with Flutter Web, featuring premium UI/UX design inspired by Shopify Plus, Apple, and Zara aesthetics.

## 🎨 Design Philosophy

- **Aesthetic**: Clean, minimalist, and trustworthy
- **Colors**: Off-white backgrounds (#FAFAFA), dark crisp typography, deep indigo primary (#1A1A2E)
- **Typography**: Inter font family for modern, readable text
- **Interactions**: Professional with shimmer loaders, subtle shadows, and smooth animations
- **Responsive**: Flawlessly adapts to mobile, tablet, and desktop screens

## 🏗️ Architecture

Built with **Clean Architecture** principles:

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/          # App constants, messages
│   ├── theme/              # Colors, text styles, theme data
│   ├── utils/              # Responsive, spacing, extensions
│   └── widgets/            # Reusable UI components
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── products/          # Product catalog
│   ├── cart/              # Shopping cart
│   ├── orders/            # Order management
│   └── admin/             # Admin panel
└── routing/               # Navigation configuration
```

## 🛠️ Tech Stack

- **Framework**: Flutter Web
- **State Management**: Riverpod (AsyncNotifier/Notifier patterns)
- **Routing**: GoRouter (web-standard URLs)
- **Networking**: Dio (with JWT interceptors)
- **Storage**: SharedPreferences (JWT persistence)
- **UI Components**: Material 3 with custom theming

## 📦 Dependencies

```yaml
# State Management
flutter_riverpod: ^2.4.9
riverpod_annotation: ^2.3.3

# Routing
go_router: ^13.0.0

# Networking
dio: ^5.4.0

# UI
shimmer: ^3.0.0
google_fonts: ^6.1.0
iconsax: ^0.0.8
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run -d chrome
   ```

3. **Build for production**:
   ```bash
   flutter build web
   ```

## 🎯 Features (Planned Implementation)

### STEP 1 - Foundation ✅ COMPLETE
- [x] Clean Architecture folder structure
- [x] GoRouter configuration with all routes
- [x] Professional ThemeData (colors, typography)
- [x] Responsive utilities
- [x] Core constants and extensions

### STEP 2 - Networking & Auth (Next)
- [ ] Dio API Client with JWT interceptors
- [ ] AuthRepository and AuthProvider
- [ ] Login screen UI
- [ ] Register screen UI
- [ ] JWT token persistence

### STEP 3 - Product Catalog
- [ ] Home screen with featured products
- [ ] Product listing with pagination
- [ ] Product details screen
- [ ] Category filtering
- [ ] Search functionality
- [ ] Shimmer loading states

### STEP 4 - Cart & Checkout
- [ ] Cart UI with item management
- [ ] Subtotal calculations
- [ ] Checkout form
- [ ] Address validation

### STEP 5 - Orders & Payment
- [ ] Order placement
- [ ] Razorpay web integration
- [ ] Order history dashboard
- [ ] Order tracking
- [ ] Payment verification

## 🎨 Design System

### Colors
- **Primary**: #1A1A2E (Deep Indigo)
- **Accent**: #D4A574 (Elegant Gold)
- **Background**: #FAFAFA (Off-White)
- **Text Primary**: #1A1A1A (Dark Crisp)
- **Success**: #2E7D32 (Green)
- **Error**: #D32F2F (Red)

### Typography (Inter Font Family)
- **Display Large**: 57px / Bold
- **Headline Large**: 32px / SemiBold
- **Title Large**: 22px / SemiBold
- **Body Large**: 16px / Regular
- **Button**: 14px / SemiBold

### Spacing (4px Grid System)
- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- XXL: 48px

### Responsive Breakpoints
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: 900px - 1200px
- Large Desktop: > 1200px

## 🔌 Backend API

Connects to Spring Boot backend running on `http://localhost:8081/api`

### Endpoints
- `/auth/login` - User authentication
- `/auth/register` - User registration
- `/products` - Product catalog
- `/cart` - Shopping cart operations
- `/orders` - Order management
- `/payments` - Razorpay integration

## 📱 Supported Platforms

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ⚠️ Mobile (planned)
- ⚠️ Desktop (planned)

## 🔒 Security

- JWT token-based authentication
- Automatic token injection via Dio interceptors
- Global 401 handling with auto-redirect to login
- Secure token storage using SharedPreferences

## 📄 License

Private project - All rights reserved

## 👥 Contributors

Built with ❤️ by the development team

---

**Current Status**: STEP 1 Complete ✅
**Next Step**: STEP 2 - Core Networking & Authentication
