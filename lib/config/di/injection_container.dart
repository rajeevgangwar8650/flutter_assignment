import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/dio_interceptor.dart';
import '../../core/network/network_info.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/shared_preferences_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/data_sources/profile_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_imp.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/stocks/data/data_sources/stocks_data_source.dart';
import '../../features/stocks/data/data_sources/stocks_socket_service.dart';
import '../../features/stocks/data/repositories/stocks_repository_imp.dart';
import '../../features/stocks/domain/repositories/stocks_repository.dart';
import '../../features/stocks/domain/usecases/stocks_usecase.dart';
import '../../features/stocks/presentation/bloc/stocks_bloc.dart';

final GetIt injector = GetIt.instance;

Future<void> initDependencies() async {
  if (injector.isRegistered<SharedPreferences>()) return;

  final sharedPreferences = await SharedPreferences.getInstance();

  injector
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences)
    ..registerLazySingleton<LoggerService>(LoggerService.new)
    ..registerLazySingleton<SharedPreferencesService>(
      () => SharedPreferencesService(injector()),
    )
    ..registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.instance,
    )
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(injector()))
    ..registerLazySingleton<AppLoggingInterceptor>(
      () => AppLoggingInterceptor(logger: injector()),
    )
    ..registerLazySingleton<AppErrorInterceptor>(AppErrorInterceptor.new)
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const <String, dynamic>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      dio.interceptors.addAll([
        injector<AppLoggingInterceptor>(),
        injector<AppErrorInterceptor>(),
      ]);
      return dio;
    })
    ..registerLazySingleton<ApiClient>(() => ApiClient(injector()))
    // Auth
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(injector()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(injector()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: injector(),
        localDataSource: injector(),
      ),
    )
    ..registerLazySingleton<SignInUseCase>(() => SignInUseCase(injector()))
    ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(injector()))
    ..registerLazySingleton<RestoreSessionUseCase>(
      () => RestoreSessionUseCase(injector()),
    )
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        signInUseCase: injector(),
        logoutUseCase: injector(),
        restoreSessionUseCase: injector(),
      ),
    )
    // Profile
    ..registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(injector()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(injector()),
    )
    ..registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(injector()),
    )
    ..registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(injector()),
    )
    ..registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getProfileUseCase: injector(),
        updateProfileUseCase: injector(),
      ),
    )
    // Stocks
    ..registerFactory<StocksSocketService>(StocksSocketService.new)
    ..registerFactory<StocksDataSource>(() => StocksDataSourceImpl(injector()))
    ..registerFactory<StocksRepository>(() => StocksRepositoryImpl(injector()))
    ..registerFactory<GetStockDashboardUseCase>(
      () => GetStockDashboardUseCase(injector()),
    )
    ..registerFactory<ConnectLiveIndicesUseCase>(
      () => ConnectLiveIndicesUseCase(injector()),
    )
    ..registerFactory<DisconnectLiveIndicesUseCase>(
      () => DisconnectLiveIndicesUseCase(injector()),
    )
    ..registerFactory<WatchLiveIndicesUseCase>(
      () => WatchLiveIndicesUseCase(injector()),
    )
    ..registerFactory<StocksBloc>(
      () => StocksBloc(
        getStockDashboardUseCase: injector(),
        connectLiveIndicesUseCase: injector(),
        disconnectLiveIndicesUseCase: injector(),
        watchLiveIndicesUseCase: injector(),
      ),
    );
}
