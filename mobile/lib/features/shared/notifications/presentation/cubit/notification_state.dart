part of 'notification_cubit.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

/// Full list snapshot. [unreadCount] mirrors the server count so the bell
/// badge stays correct without a second source of truth.
class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  NotificationSuccess(this.notifications, this.unreadCount);
}

/// The cheap unread-count poll ticked while the list isn't loaded yet —
/// the screen treats it like "still loading".
class NotificationCountChanged extends NotificationState {
  final int unreadCount;
  NotificationCountChanged(this.unreadCount);
}

class NotificationFailure extends NotificationState {
  final String errorMessage;
  NotificationFailure(this.errorMessage);
}
