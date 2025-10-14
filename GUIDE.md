# 🎯 Hướng dẫn sử dụng

## 🚀 Khởi chạy nhanh

### 1. Clone và cài đặt
```bash
git clone <your-repo-url>
cd flutter-app-template
flutter pub get
```

### 2. Chạy ứng dụng
```bash
flutter run
```

### 3. Build cho production
```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

## 🏗️ Cách thêm feature mới

### 1. Tạo cấu trúc thư mục
```bash
mkdir -p lib/features/new_feature/{data,domain,presentation}
mkdir -p lib/features/new_feature/data/{datasources,models,repositories}
mkdir -p lib/features/new_feature/domain/{entities,repositories,usecases}
mkdir -p lib/features/new_feature/presentation/{bloc,pages,widgets}
```

### 2. Example: Tạo User feature

**Entity (domain/entities/user.dart):**
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [id, name, email];
}
```

**Model (data/models/user_model.dart):**
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

**Repository Interface (domain/repositories/user_repository.dart):**
```dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, User>> getUser(int id);
  Future<Either<Failure, User>> createUser(User user);
}
```

**Use Case (domain/usecases/get_users.dart):**
```dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  Future<Either<Failure, List<User>>> call() async {
    return await repository.getUsers();
  }
}
```

**Data Source (data/datasources/user_remote_data_source.dart):**
```dart
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await apiClient.getPosts(); // Adjust endpoint
    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<UserModel> getUser(int id) async {
    final response = await apiClient.getPost(id); // Adjust endpoint
    return UserModel.fromJson(response);
  }
}
```

**Repository Implementation (data/repositories/user_repository_impl.dart):**
```dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/error_handler.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();
      return Right(users);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> getUser(int id) async {
    try {
      final user = await remoteDataSource.getUser(id);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> createUser(User user) async {
    // Implementation here
    throw UnimplementedError();
  }
}
```

**BLoC (presentation/bloc/user_bloc.dart):**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users.dart';

// Events
abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadUsers extends UserEvent {}

// States
abstract class UserState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;

  UserLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsers getUsers;

  UserBloc(this.getUsers) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final result = await getUsers();
    result.fold(
      (failure) => emit(UserError(ErrorHandler.getDisplayMessage(failure))),
      (users) => emit(UserLoaded(users)),
    );
  }
}
```

### 3. Đăng ký Dependencies

**Trong injection_container.dart:**
```dart
// Thêm vào hàm init()
void _initUser() {
  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );
  
  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetUsers(sl()));
  
  // BLoC
  sl.registerFactory(() => UserBloc(sl()));
}
```

### 4. Sử dụng trong UI

**User Page:**
```dart
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserBloc>()..add(LoadUsers()),
      child: Scaffold(
        appBar: AppBar(title: Text('Users')),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return LoadingWidget();
            } else if (state is UserError) {
              return ErrorWidget(message: state.message);
            } else if (state is UserLoaded) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                  );
                },
              );
            }
            return EmptyWidget(message: 'No users found');
          },
        ),
      ),
    );
  }
}
```

## 🔧 Công cụ hữu ích

### Code Generation
```bash
# Generate JSON serialization
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Debugging
- Sử dụng VS Code debugger
- Flutter Inspector trong DevTools
- Network logs trong console

## 📝 Best Practices

1. **Đặt tên**: Sử dụng tên có ý nghĩa và nhất quán
2. **Error Handling**: Luôn xử lý lỗi properly
3. **Testing**: Viết tests cho business logic
4. **Documentation**: Comment code phức tạp
5. **Performance**: Sử dụng const widgets khi có thể

## 🤔 FAQ

**Q: Làm sao để thêm API endpoint mới?**
A: Thêm method trong `ApiClient` class và update `DioClient` nếu cần.

**Q: Làm sao để thay đổi theme?**
A: Chỉnh sửa trong `AppTheme` class, có thể thêm theme mới.

**Q: Làm sao để add animations?**
A: Sử dụng Flutter animations hoặc thêm packages như `flutter_animate`.

**Q: Database local nào nên dùng?**
A: SharedPreferences cho simple data, Hive cho complex objects, SQLite cho relational data.
