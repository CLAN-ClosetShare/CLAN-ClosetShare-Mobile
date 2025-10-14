import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Storage
  sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sl()));

  // Dio
  sl.registerLazySingleton(() => Dio());

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

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
