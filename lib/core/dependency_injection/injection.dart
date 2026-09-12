import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../../data/datasources/user_datasource.dart';
import '../../data/repositories/user_repository.dart';
import '../../presentation/cubit/user_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<Dio>(
        () => DioClient().dio,
  );

  getIt.registerLazySingleton<UserDataSource>(
        () => UserDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<UserRepository>(
        () => UserRepository(getIt<UserDataSource>()),
  );

  getIt.registerFactory<UserCubit>(
        () => UserCubit(getIt<UserRepository>()),
  );
}