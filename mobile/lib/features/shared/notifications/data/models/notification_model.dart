import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? createdAt;
  final int? orderId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'in_app',
    this.isRead = false,
    this.createdAt,
    this.orderId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'in_app',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      orderId: (json['data'] as Map<String, dynamic>?)?['order_id'] as int?,
    );
  }

  /// Builds a live incoming-push item for the in-memory list. Push payloads
  /// carry no server row id, so a negative timestamp-based id is used to keep
  /// it on top and avoid colliding with server ids; the next server refresh
  /// replaces it with the authoritative row.
  factory NotificationModel.incoming({
    required String title,
    required String message,
    Map<String, dynamic> data = const {},
    DateTime? createdAt,
  }) {
    final ts = createdAt ?? DateTime.now();
    return NotificationModel(
      id: -(ts.millisecondsSinceEpoch ~/ 1000),
      title: title,
      message: message,
      type: 'push',
      isRead: false,
      createdAt: ts.toUtc().toIso8601String(),
      orderId: int.tryParse(data['order_id']?.toString() ?? ''),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      orderId: orderId,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt, orderId];
}
