# Naseej - Egyptian Handmade Carpets E-Commerce App 

<div align="center">

![Naseej Logo](assets/images/icon1.png)

A premium mobile e-commerce platform for authentic Egyptian handmade carpets

</div>

---

## 📱 About The Project

Naseej is a modern, feature-rich Flutter application that brings the timeless beauty of Egyptian handcrafted carpets to your fingertips. Built with a focus on user experience, performance, and cultural authenticity, this app bridges traditional craftsmanship with cutting-edge mobile technology.

### 🎯 Key Highlights

- **Family Business Heritage**: Three generations of expertise in Egyptian carpet craftsmanship
- **Complete E-Commerce Solution**: Full-featured shopping experience from browsing to checkout
- **Multi-Language Support**: Arabic, English, French, German, and Spanish
- **Advanced Features**: Real-time search, favorites management, order tracking, and more

---

## ✨ Features

### 🛍️ Shopping Experience

#### Product Catalog
- Grid and list views with high-quality images
- Advanced filtering (category, price, size, color)
- Real-time search with auto-suggestions
- Special offers and discount badges
- New arrivals section
- Free shipping eligibility indicators

#### Product Details
- Interactive image gallery with zoom
- Size and color selection
- Stock availability checking
- Related products recommendations
- Customer reviews and ratings

### 🛒 Cart & Checkout

#### Smart Cart Management
- Add/remove items with animations
- Quantity adjustment
- Real-time price calculations
- Free shipping threshold tracking
- Persistent cart across sessions

#### Flexible Checkout
- Multiple delivery options (home delivery/store pickup)
- Payment methods (Cash on Delivery/Online Payment)
- Saved addresses and payment methods
- Order notes and special instructions
- Real-time order summary

### 👤 User Account

#### Profile Management
- Profile picture upload with image picker
- Personal information editing
- Order history tracking
- Favorites collection
- Address book management
- Payment methods storage

#### Authentication
- Email/Password registration
- Email verification with OTP
- Secure login system
- Password recovery flow
- Account deletion option

### 📍 Store Locator

#### Find Physical Stores
- Interactive store list
- Distance calculation from user location
- Store details (hours, contact, reviews)
- Filter by city and region
- Store-specific pickup options

### 📦 Order Management

#### Order Tracking
- Real-time order status updates
- Order history with filtering
- Detailed order information
- Reorder functionality
- Order cancellation (when applicable)

### ⚙️ Settings & Preferences

#### Customization
- Theme selection (Light/Dark/System)
- Language preferences
- Notification settings
- Auto-save preferences

#### Security
- Password change functionality
- Account deletion with confirmation
- Secure token-based authentication

### 🌐 Additional Features

#### Internet Connectivity
- Offline detection
- Auto-reconnection handling
- Cached data management

#### UI/UX Enhancements
- Smooth animations and transitions
- Pull-to-refresh functionality
- Loading states and skeletons
- Error handling with retry options
- Haptic feedback

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── auth/                          # Authentication screens
│   ├── login.dart
│   ├── register.dart
│   ├── otp_verification_page.dart
│   ├── forget_password_email.dart
│   ├── forget_password_otp.dart
│   └── reset_password.dart
│
├── pages/                         # Main application pages
│   ├── home_page.dart            # Landing page with promotions
│   ├── explore_page.dart         # Product catalog
│   ├── cart_page.dart            # Shopping cart
│   ├── checkout_page.dart        # Checkout process
│   ├── orders_page.dart          # Order management
│   ├── order_details_page.dart   # Order details view
│   ├── profile_page.dart         # User profile
│   ├── settings_page.dart        # App settings
│   ├── stores_page.dart          # Store locator
│   ├── favorites_page.dart       # Saved products
│   ├── product_details_page.dart # Product details
│   ├── special_offers_page.dart  # Discounted products
│   ├── new_arrivals_page.dart    # Latest products
│   ├── free_shipping_page.dart   # Free shipping products
│   ├── shop_page.dart            # Category-filtered products
│   ├── about_page.dart           # About the business
│   ├── main_container.dart       # Bottom navigation container
│   ├── address/                  # Address management
│   │   ├── addresspage.dart
│   │   ├── add_address_page.dart
│   │   └── edit_address_page.dart
│   └── payment/                  # Payment management
│       ├── payment_methods_page.dart
│       ├── add_payment_method_page.dart
│       └── edit_payment_method_page.dart
│
├── component/                     # Reusable components
│   ├── product_card.dart         # Product display card
│   ├── store_card.dart           # Store display card
│   ├── app_drawer.dart           # Navigation drawer
│   ├── button.dart               # Custom button widget
│   ├── textformfield.dart        # Custom text input
│   ├── logo.dart                 # App logo widget
│   ├── crud.dart                 # API request handler
│   └── internet_checker_widget.dart
│
├── core/                          # Core functionality
│   ├── constant/                 # App constants
│   │   ├── app_colors.dart       # Color scheme
│   │   ├── linkapi.dart          # API endpoints
│   │   └── imgaeasset.dart       # Image assets
│   │
│   ├── services/                 # Business logic services
│   │   ├── cart_service.dart
│   │   ├── orders_service.dart
│   │   ├── address_service.dart
│   │   ├── payment_service.dart
│   │   ├── store_service.dart
│   │   └── profile_service.dart
│   │
│   ├── functions/                # Utility functions
│   │   └── checkinternet.dart
│   │
│   └── middleware/               # App middleware
│       └── internet_middleware.dart
│
├── models/                        # Data models
│   ├── product_model.dart
│   ├── cart_item.dart
│   ├── order_model.dart
│   ├── address_model.dart
│   ├── payment_method_model.dart
│   └── store_model.dart
│
├── utils/                         # Utility classes
│   ├── favorites_manager.dart    # Favorites management
│   ├── language_manager.dart     # Localization
│   ├── theme_manager.dart        # Theme management
│   └── helpsupport.dart          # Help & support
│
├── onboarding/                    # Onboarding screens
│   └── onboarding.dart
│
├── routes.dart                    # App routing configuration
└── main.dart                      # App entry point
```

### Design Patterns

- **Service Layer Pattern**: Separation of business logic from UI
- **Repository Pattern**: Data access abstraction
- **Singleton Pattern**: Shared preferences and managers
- **Factory Pattern**: Model creation from JSON
- **Observer Pattern**: State management with setState and callbacks

### State Management

- **Local State**: `setState()` for component-level state
- **Shared Preferences**: Persistent storage for user preferences
- **Service Layer**: Centralized business logic and API calls
- **Callbacks**: Parent-child component communication

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extension
- iOS Simulator / Android Emulator
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/naseej-app.git
   cd naseej-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   
   Update `lib/core/constant/linkapi.dart` with your backend URL:
   ```dart
   class AppLink {
     static const String server = "https://your-backend-url.com";
     // ... rest of endpoints
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Environment Setup

Create a `.env` file in the root directory (optional for production):

```env
API_BASE_URL=https://your-backend-url.com
API_KEY=your-api-key
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & Navigation
  get: ^4.6.6
  
  # Network & API
  http: ^1.1.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # UI Components
  pin_code_fields: ^8.0.1
  lottie: ^2.7.0
  font_awesome_flutter: ^10.6.0
  
  # Image Handling
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0
  
  # Utilities
  url_launcher: ^6.2.1
  connectivity_plus: ^5.0.1
  intl: ^0.18.1
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.13.1
```

---

## 🔌 API Documentation

### Base URL
```
https://your-backend-url.com/api
```

### Authentication Endpoints

#### Register User
```http
POST /auth/signup
Content-Type: application/json

{
  "name": "string",
  "email": "string",
  "phone": "string",
  "password": "string",
  "confirm_password": "string"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "string",
  "password": "string"
}

Response:
{
  "status": "success",
  "data": {
    "user": { ... },
    "token": "Bearer token"
  }
}
```

#### Verify Email
```http
POST /auth/verify-email
Content-Type: application/json

{
  "email": "string",
  "otp": "string"
}
```

### Product Endpoints

#### Get All Products
```http
POST /products/all
Authorization: Bearer {token}
Content-Type: application/json

{
  "user_id": "string",
  "category_id": "string" // optional
}
```

#### Get Product Details
```http
POST /products/details
Content-Type: application/json

{
  "product_id": "string"
}
```

#### Get Special Offers
```http
POST /products/special-offers
Authorization: Bearer {token}
```

### Cart Endpoints

#### Get Cart
```http
POST /cart/get
Authorization: Bearer {token}
```

#### Add to Cart
```http
POST /cart/add
Authorization: Bearer {token}
Content-Type: application/json

{
  "product_id": "string",
  "quantity": number,
  "color": "string", // optional
  "size": "string" // optional
}
```

#### Update Cart Item
```http
POST /cart/update
Authorization: Bearer {token}
Content-Type: application/json

{
  "cart_id": "string",
  "quantity": number
}
```

### Order Endpoints

#### Create Order
```http
POST /orders/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "delivery_method": "delivery|pickup",
  "payment_type": "cash|online",
  "address_id": "string", // required for delivery
  "store_id": "string", // required for pickup
  "payment_method_id": "string", // optional
  "notes": "string" // optional
}
```

#### Get Orders
```http
POST /orders/get
Authorization: Bearer {token}
```

#### Get Order Details
```http
POST /orders/details
Authorization: Bearer {token}
Content-Type: application/json

{
  "order_id": "string"
}
```

### Favorites Endpoints

#### Get Favorites
```http
POST /favorites/get
Authorization: Bearer {token}
Content-Type: application/json

{
  "customer_id": "string"
}
```

#### Toggle Favorite
```http
POST /favorites/toggle
Authorization: Bearer {token}
Content-Type: application/json

{
  "customer_id": "string",
  "product_id": "string"
}
```

### Store Endpoints

#### Search Stores
```http
POST /stores/search
Authorization: Bearer {token}
Content-Type: application/json

{
  "query": "string", // optional
  "city": "string", // optional
  "region": "string" // optional
}
```

---

## 🎨 Theme & Styling

### Color Palette

```dart
class AppColor {
  // Primary Colors
  static const Color primaryColor = Color(0xFF8B4513);      // Saddle Brown
  static const Color secondColor = Color(0xFFD2691E);       // Chocolate
  static const Color goldAccent = Color(0xFFD4AF37);        // Gold
  
  // Neutral Colors
  static const Color grey = Color(0xFF9E9E9E);
  static const Color backgroundcolor = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFF44336);
  
  // Earth Tones
  static const Color earthBrown = Color(0xFF8B7355);
  static const Color bronzeAccent = Color(0xFFCD7F32);
}
```

### Typography

- **Display**: Playfair Display (Headers)
- **Body**: System Default (Roboto/SF Pro)

### Dark Mode Support

The app includes comprehensive dark mode support with:
- Automatic system theme detection
- Manual theme toggle
- Persistent theme preference
- Properly contrasted UI elements

### Adding New Languages

1. Create translation files in `assets/lang/`
2. Add language to `LanguageManager.getSupportedLanguages()`
3. Update language selection UI in settings

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/
├── unit/
│   ├── services/
│   ├── models/
│   └── utils/
├── widget/
│   ├── components/
│   └── pages/
└── integration/
    └── user_flows/
```

---

## 📱 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Output location
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build IPA
flutter build ios --release

# Output location
build/ios/ipa/naseej.ipa
```

### Build Configuration

Update version and build number in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open a Pull Request**

### Code Style

- Follow [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Write meaningful commit messages
- Add comments for complex logic

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 Contact

**Project Maintainer**: Your Name
- Email: yasserashraf3142@gmail.com

<div align="center">
Made with ❤️ for preserving Egyptian heritage through technology
</div>

