# CloseShare App

Ứng dụng chia sẻ tủ đồ thông minh với Clean Architecture, phát triển cho cả iOS và Android.

## ✨ Tính năng có sẵn

### 🏗️ Kiến trúc
- **Clean Architecture** với cấu trúc rõ ràng
- **Dependency Injection** với GetIt
- **State Management** với BLoC/Cubit

### 🌐 Mạng & API
- **Dio HTTP Client** đã cấu hình sẵn
- **Retrofit** cho type-safe API calls
- **Error handling** tự động
- **Logging interceptors**

### 💾 Lưu trữ
- **SharedPreferences** cho dữ liệu đơn giản
- **Hive** cho dữ liệu phức tạp
- **Local storage abstraction**

### 🎨 Giao diện
- **Material Design 3** theme
- **Dark/Light mode** support
- **Custom widgets** có thể tái sử dụng
- **Responsive design**

### 🛠️ Utilities
- **Custom Button** component
- **Custom TextField** component
- **Loading/Error/Empty** states
- **Cached network images**
- **SVG support**

## 📁 Cấu trúc dự án

```
lib/
├── core/                   # Core functionality
│   ├── di/                # Dependency injection
│   ├── network/           # HTTP client & API
│   ├── storage/           # Local storage
│   └── theme/             # App themes
├── features/              # Features by domain
│   └── home/
│       └── presentation/  # UI layer
│           └── pages/
├── shared/                # Shared components
│   └── widgets/           # Reusable widgets
└── main.dart             # App entry point

assets/
├── images/               # Image assets
├── icons/                # Icon assets
└── fonts/                # Font assets
```

## 🚀 Cài đặt và chạy

### Yêu cầu
- Flutter SDK (>= 3.8.1)
- Dart SDK
- Android Studio / Xcode cho development

### Cài đặt dependencies
```bash
flutter pub get
```

### Chạy ứng dụng
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### Build cho sản xuất
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔧 Cấu hình

### API Base URL
Thay đổi base URL trong `lib/core/network/dio_client.dart`:
```dart
baseUrl: 'https://your-api-domain.com/api/',
```

### Theme Colors
Tùy chỉnh màu sắc trong `lib/core/theme/app_theme.dart`.

### App Icons & Name
- Android: `android/app/src/main/res/`
- iOS: `ios/Runner/Assets.xcassets/`
- App name: `pubspec.yaml` và platform-specific files

## 📱 Platform Support

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest
- Support cho Material Design 3

### iOS
- Minimum version: iOS 12.0
- Support cho adaptive UI
- Dark mode tự động

## 🎯 Cách sử dụng

### 1. Thêm Feature mới
```bash
lib/features/new_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### 2. Gọi API
```dart
final apiClient = sl<ApiClient>();
final response = await apiClient.getPosts();
```

### 3. Lưu trữ dữ liệu
```dart
final storage = sl<LocalStorage>();
await storage.saveString('key', 'value');
```

### 4. State Management với BLoC
```dart
// Event
class LoadPosts extends HomeEvent {}

// State  
class PostsLoaded extends HomeState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadPosts>(_onLoadPosts);
  }
}
```

## 📦 Dependencies chính

- `flutter_bloc`: State management
- `dio`: HTTP client
- `get_it`: Dependency injection  
- `shared_preferences`: Simple storage
- `hive`: Complex storage
- `cached_network_image`: Image caching
- `flutter_svg`: SVG support

## 🤝 Contributing

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

Dự án này được phân phối dưới MIT License. Xem file `LICENSE` để biết thêm chi tiết.

---

⭐ Nếu template này hữu ích, đừng quên star repo nhé!
