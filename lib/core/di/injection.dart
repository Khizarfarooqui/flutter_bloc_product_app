import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';


import '../network/dio_client.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/presentation/blocs/dashboard_cubit.dart';
import '../../features/product/presentation/blocs/product_cubit.dart';
import '../../features/product/presentation/blocs/settings_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initInjector() async {
  sl.registerLazySingleton<Dio>(() => createDio());
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ProductRepositoryImpl>(
    () => ProductRepositoryImpl(dataSource: sl<ProductRemoteDataSource>()),
  );
  sl.registerFactory<ProductListCubit>(
    () => ProductListCubit(repository: sl<ProductRepositoryImpl>()),
  );
  sl.registerFactory<ProductDetailCubit>(
    () => ProductDetailCubit(repository: sl<ProductRepositoryImpl>()),
  );
  sl.registerFactory<ProductFormCubit>(
    () => ProductFormCubit(repository: sl<ProductRepositoryImpl>()),
  );
  sl.registerFactory<DashboardCubit>(() => DashboardCubit());
  sl.registerFactory<SettingsCubit>(() => SettingsCubit());
}
