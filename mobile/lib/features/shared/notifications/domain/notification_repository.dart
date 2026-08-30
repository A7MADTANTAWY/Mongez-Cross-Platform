import 'package:dartz/dartz.dart';
import 'package:mongez/core/error/failure.dart';
import 'package:mongez/features/shared/notifications/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    int page = 1,
    int? pageSize,
  });
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(int id);
  Future<Either<Failure, void>> markAllAsRead();
}
