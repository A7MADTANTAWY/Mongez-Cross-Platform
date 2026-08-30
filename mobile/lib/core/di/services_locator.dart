import 'package:get_it/get_it.dart';
import 'package:mongez/features/auth/repos/auth_repository.dart';
import 'package:mongez/features/client/address/data/repositories/address_repository.dart';
import 'package:mongez/features/auth/repos/governorates_repo.dart';
import 'package:mongez/features/client/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:mongez/features/client/favorites/domain/favorites_repository.dart';
import 'package:mongez/features/client/home/data/repositories/home_repo.dart';
import 'package:mongez/features/client/home/data/repositories/home_repo_implementation.dart';
import 'package:mongez/features/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:mongez/features/shared/notifications/domain/notification_repository.dart';
import 'package:mongez/features/client/order/data/repositories/order_repository_impl.dart';
import 'package:mongez/features/client/order/domain/order_repository.dart';
import 'package:mongez/features/shared/profile/data/repositories/profile_repository_impl.dart';
import 'package:mongez/features/shared/profile/domain/profile_repository.dart';
import 'package:mongez/features/shared/workers/data/repositories/worker_repository_impl.dart';
import 'package:mongez/features/shared/workers/domain/worker_repository.dart';
import 'package:mongez/core/network/api_client.dart';
import 'package:mongez/core/network/api_service.dart';

final getIt = GetIt.instance;

void setup() {
  final apiService = ApiService(DioClient());
  getIt.registerLazySingleton<ApiService>(() => apiService);

  // Auth
  getIt.registerLazySingleton(
    () => AuthRepository(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<GovernoratesRepo>(
    () => GovernoratesRepo(getIt.get<ApiService>()),
  );

  // Addresses (default address shared by Home + Account)
  getIt.registerLazySingleton(
    () => AddressRepository(getIt.get<ApiService>()),
  );

  // Home / Categories
  getIt.registerLazySingleton<HomeRepo>(
    () => HomeRepoImplementation(getIt.get<ApiService>()),
  );

  // Workers
  getIt.registerLazySingleton<WorkerRepository>(
    () => WorkerRepositoryImpl(getIt.get<ApiService>()),
  );

  // Orders
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt.get<ApiService>()),
  );

  // Favorites
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt.get<ApiService>()),
  );

  // Profile
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt.get<ApiService>()),
  );

  // Notifications
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt.get<ApiService>()),
  );
}
