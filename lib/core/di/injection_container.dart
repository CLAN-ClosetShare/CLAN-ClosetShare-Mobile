import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../network/fetcher.dart';
import '../storage/local_storage.dart';
import '../repositories/auth_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Load environment
  await dotenv.load();

  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Storage
  sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sl()));

  // Dio
  sl.registerLazySingleton(() => Dio());

  // Network: create DioClient first so it can configure BaseOptions (baseUrl)
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      sl(),
      storage: sl<LocalStorage>(),
    ),
  );

  // Repositories: create AuthRepository using the Dio instance from DioClient
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<DioClient>().dio, sl<LocalStorage>()),
  );

  // Wire back the authRepository into DioClient so interceptor can call refresh
  sl<DioClient>().authRepository = sl<AuthRepository>();
  sl.registerLazySingleton<Fetcher>(() => Fetcher(sl<Dio>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<DioClient>()));

  // Features - sẽ thêm khi tạo features mới
  // _initAuth();
  // _initHome();
}

// Future<void> _initAuth() async {
//   // Auth feature dependencies
// }

// Future<void> _initHome() async {
//   // Home feature dependencies
// }
