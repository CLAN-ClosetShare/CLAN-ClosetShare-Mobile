import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:io';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../network/fetcher.dart';
import '../storage/local_storage.dart';
import '../repositories/auth_repository.dart';
import '../../features/closet/data/datasources/closet_remote_data_source.dart';
import '../../features/closet/data/datasources/closet_remote_data_source_impl.dart';
import '../../features/closet/data/repositories/closet_repository_impl.dart';
import '../../features/closet/domain/repositories/closet_repository.dart';
import '../../features/closet/domain/usecases/closet_usecases.dart';
import '../../features/closet/domain/usecases/closet_item_usecases.dart';
import '../../features/closet/presentation/bloc/closet_bloc.dart';
import '../../features/closet/presentation/bloc/closet_item_bloc.dart';

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

  // Create a PersistCookieJar so cookies survive app restarts
  // Use path_provider to get a temp directory for persistent cookies
  final docsPath = await getTemporaryDirectory();
  final cookiePath = '${docsPath.path}/.cookies/';
  final persistCookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
  // Register cookie jar in DI so other modules can access it (e.g., for debugging)
  sl.registerLazySingleton<CookieJar>(() => persistCookieJar);

  // Network: create DioClient and inject cookieJar. AuthRepository will be created next and wired in.
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl(), storage: sl<LocalStorage>(), cookieJar: persistCookieJar),
  );

  // Repositories: create AuthRepository using the Dio instance from DioClient
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<DioClient>().dio, sl<LocalStorage>()),
  );

  // Wire back the authRepository into DioClient so interceptor can call refresh
  sl<DioClient>().authRepository = sl<AuthRepository>();
  sl.registerLazySingleton<Fetcher>(() => Fetcher(sl<Dio>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<DioClient>()));

  // Features
  _initCloset();
}

Future<void> _initCloset() async {
  // Data sources
  sl.registerLazySingleton<ClosetRemoteDataSource>(
    () => ClosetRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ClosetRepository>(() => ClosetRepositoryImpl(sl()));

  // Use cases - Closets
  sl.registerLazySingleton(() => GetClosets(sl()));
  sl.registerLazySingleton(() => GetClosetById(sl()));
  sl.registerLazySingleton(() => CreateCloset(sl()));
  sl.registerLazySingleton(() => UpdateCloset(sl()));
  sl.registerLazySingleton(() => DeleteCloset(sl()));

  // Use cases - Closet Items
  sl.registerLazySingleton(() => GetClosetItems(sl()));
  sl.registerLazySingleton(() => GetClosetItemById(sl()));
  sl.registerLazySingleton(() => CreateClosetItem(sl()));
  sl.registerLazySingleton(() => UpdateClosetItem(sl()));
  sl.registerLazySingleton(() => DeleteClosetItem(sl()));

  // BLoC
  sl.registerFactory(
    () => ClosetBloc(
      getClosets: sl(),
      createCloset: sl(),
      updateCloset: sl(),
      deleteCloset: sl(),
    ),
  );

  sl.registerFactory(
    () => ClosetItemBloc(
      getClosetItems: sl(),
      createClosetItem: sl(),
      updateClosetItem: sl(),
      deleteClosetItem: sl(),
    ),
  );
}

// Future<void> _initAuth() async {
//   // Auth feature dependencies
// }

// Future<void> _initHome() async {
//   // Home feature dependencies
// }
