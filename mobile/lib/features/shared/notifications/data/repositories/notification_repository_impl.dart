import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/error/failure.dart';
import 'package:mongez/features/shared/notifications/data/models/notification_model.dart';
import 'package:mongez/features/shared/notifications/domain/notification_repository.dart';
import 'package:mongez/core/network/api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService apiService;

  NotificationRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    int page = 1,
    int? pageSize,
  }) async {
    try {
      final data = await apiService.get(
        endPoint: Endpoints.notifications,
        queryParameters: {
          'page': page,
          'page_size': ?pageSize,
        },
      );
      final list = data as List<dynamic>? ?? [];
      final notifications =
          list.map((e) => NotificationModel.fromJson(e)).toList();
      return right(notifications);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final data = await apiService.get(endPoint: Endpoints.notificationsUnreadCount);
      final count = (data as Map<String, dynamic>)['unread'] as int? ?? 0;
      return right(count);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await apiService.post(endPoint: Endpoints.notificationRead(id));
      return right(null);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await apiService.post(endPoint: Endpoints.notificationsReadAll);
      return right(null);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errorMessage: e.toString()));
    }
  }
}
