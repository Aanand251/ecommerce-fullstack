# E-Commerce Store

A modern, full-stack e-commerce application built with Spring Boot and Flutter. This project features a robust REST API backend with JWT authentication, payment integration, and a responsive Flutter web frontend.

## Features

### Backend Features
- **Authentication & Authorization**
  - JWT-based authentication
  - Role-based access control (USER, ADMIN)
  - Secure password hashing with BCrypt
  - Custom user details service

- **Product Management**
  - CRUD operations for products
  - Category-based organization
  - Product search and filtering
  - Image URL support

- **Shopping Cart**
  - Add/remove items from cart
  - Update quantities
  - Cart persistence for authenticated users
  - Automatic cart total calculation

- **Order Management**
  - Place orders from cart
  - Order history tracking
  - Order status management (PENDING, PAID, SHIPPED, DELIVERED, CANCELLED)
  - Admin order management

- **Payment Integration**
  - Razorpay payment gateway integration
  - Secure payment verification
  - Payment status tracking
  - Duplicate payment prevention

- **Security Features**
  - Rate limiting for API endpoints
  - Request logging
  - JWT token validation
  - CORS configuration
  - Global exception handling

- **API Documentation**
  - Swagger/OpenAPI integration
  - Interactive API testing interface
  - Comprehensive endpoint documentation

### Frontend Features
- **Modern UI/UX**
  - Responsive design for all screen sizes
  - Material Design components
  - Google Fonts integration
  - Smooth animations and transitions

- **State Management**
  - Riverpod for efficient state management
  - Code generation for type-safe providers

- **Routing**
  - GoRouter for web-standard URLs
  - Deep linking support
  - Navigation guards

- **Product Browsing**
  - Product listing with categories
  - Product details view
  - Search functionality
  - Cached network images

- **Shopping Experience**
  - Shopping cart management
  - Order placement
  - Order history
  - Payment processing

- **Authentication**
  - User registration
  - Login/logout
  - JWT token persistence
  - Protected routes

## Tech Stack

### Backend
- **Framework**: Spring Boot 3.3.10
- **Language**: Java 17
- **Database**: PostgreSQL
- **Security**: Spring Security + JWT
- **ORM**: Spring Data JPA (Hibernate)
- **Payment**: Razorpay SDK
- **Documentation**: SpringDoc OpenAPI 3
- **Build Tool**: Maven

### Frontend
- **Framework**: Flutter (Web)
- **Language**: Dart 3.0+
- **State Management**: Riverpod 2.4
- **Routing**: GoRouter 13.0
- **HTTP Client**: Dio 5.4
- **UI**: Material Design + Custom Components
- **Fonts**: Google Fonts
- **Icons**: Iconsax, Cupertino Icons

## Project Structure

```
store/
├── store/                          # Backend (Spring Boot)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/example/store/
│   │   │   │   ├── controller/    # REST API Controllers
│   │   │   │   ├── dto/           # Data Transfer Objects
│   │   │   │   ├── exception/     # Exception Handlers
│   │   │   │   ├── model/         # Entity Models
│   │   │   │   ├── repository/    # JPA Repositories
│   │   │   │   ├── security/      # Security Configuration
│   │   │   │   └── service/       # Business Logic
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   ├── pom.xml
│   └── mvnw
│
└── store_frontend/                 # Frontend (Flutter)
    ├── lib/
    │   ├── core/
    │   │   ├── constants/         # App Constants
    │   │   ├── theme/             # Theme Configuration
    │   │   └── utils/             # Utility Functions
    │   └── routing/               # Route Configuration
    ├── web/                       # Web Assets
    ├── pubspec.yaml
    └── README.md
```

## Getting Started

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+
- Flutter SDK 3.0+
- Git

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd store
   ```

2. **Configure PostgreSQL Database**
   ```sql
   CREATE DATABASE ecommerce_db;
   ```

3. **Configure Application Properties**

   Copy the example configuration:
   ```bash
   cd store/src/main/resources
   cp application.properties.example application.properties
   ```

   Update `application.properties` with your credentials:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/ecommerce_db
   spring.datasource.username=your_username
   spring.datasource.password=your_password

   jwt.secret=your_jwt_secret_key_minimum_256_bits_long

   razorpay.key.id=your_razorpay_key_id
   razorpay.key.secret=your_razorpay_key_secret
   ```

4. **Build and Run**
   ```bash
   cd store
   ./mvnw clean install
   ./mvnw spring-boot:run
   ```

   The API will be available at `http://localhost:8081`

5. **Access Swagger UI**

   Open your browser and navigate to:
   ```
   http://localhost:8081/swagger-ui/index.html
   ```

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd store_frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation (for Riverpod)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API endpoint**

   Update the API base URL in `lib/core/constants/app_constants.dart`:
   ```dart
   static const String apiBaseUrl = 'http://localhost:8081';
   ```

5. **Run the application**
   ```bash
   flutter run -d chrome
   ```

   Or for production build:
   ```bash
   flutter build web
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Products
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create product (Admin)
- `PUT /api/products/{id}` - Update product (Admin)
- `DELETE /api/products/{id}` - Delete product (Admin)

### Categories
- `GET /api/categories` - Get all categories
- `POST /api/categories` - Create category (Admin)

### Cart
- `GET /api/cart` - Get user cart
- `POST /api/cart/add?productId={id}&quantity={qty}` - Add to cart
- `DELETE /api/cart/remove/{productId}` - Remove from cart
- `PUT /api/cart/update` - Update cart item quantity

### Orders
- `POST /api/orders/place` - Place order
- `GET /api/orders/my-orders` - Get user orders
- `GET /api/orders/{id}` - Get order details

### Admin
- `GET /api/admin/users` - Get all users
- `PUT /api/admin/users/{id}/role` - Change user role

## Security Configuration

### Rate Limiting
- **Authentication endpoints**: 5 requests per 60 seconds
- **API endpoints**: 100 requests per 60 seconds
- **Admin endpoints**: 50 requests per 60 seconds

### JWT Configuration
- Token expiration: 24 hours (86400000 ms)
- HS256 algorithm for signing
- Bearer token authentication

## Database Schema

### Main Entities
- **User**: User accounts with roles
- **Product**: Product information
- **Category**: Product categories
- **Cart**: Shopping cart
- **CartItem**: Items in cart
- **Order**: Customer orders
- **OrderItem**: Items in order
- **Payment**: Payment transactions

## Development

### Running Tests
```bash
# Backend tests
cd store
./mvnw test

# Frontend tests
cd store_frontend
flutter test
```

### Code Generation (Frontend)
```bash
flutter pub run build_runner watch
```

### Building for Production

**Backend:**
```bash
cd store
./mvnw clean package
java -jar target/store-0.0.1-SNAPSHOT.jar
```

**Frontend:**
```bash
cd store_frontend
flutter build web --release
```

## Environment Variables

### Backend
Create environment variables or update `application.properties`:
- `DB_URL`: PostgreSQL connection URL
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password
- `JWT_SECRET`: Secret key for JWT
- `RAZORPAY_KEY_ID`: Razorpay API key
- `RAZORPAY_KEY_SECRET`: Razorpay secret key

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is created for educational purposes.

## Contact

For questions or support, please open an issue in the repository.

## Acknowledgments

- Spring Boot team for the excellent framework
- Flutter team for the amazing cross-platform framework
- Razorpay for payment integration
- All open-source contributors

---

**Note**: This is a demonstration project. For production use, ensure proper security auditing, testing, and configuration management.
