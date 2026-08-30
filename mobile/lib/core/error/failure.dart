// ignore: file_names
import 'package:dio/dio.dart';
import 'package:mongez/generated/l10n.dart';

abstract class Failure {
  final String errorMessage;

  const Failure({required this.errorMessage});
}

class ServerFailure extends Failure {
  ServerFailure({required super.errorMessage});

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return ServerFailure(
          errorMessage: S.current.requestCancelled,
        );
      case DioExceptionType.connectionTimeout:
        return ServerFailure(
          errorMessage: S.current.connectionTimeout,
        );
      case DioExceptionType.receiveTimeout:
        return ServerFailure(
          errorMessage: S.current.receiveTimeout,
        );
      case DioExceptionType.badResponse:
        final data = dioException.response?.data;
        String message = S.current.somethingWentWrong;

        if (data is Map) {
          if (data.containsKey('non_field_errors')) {
            message = _firstString(data['non_field_errors']);
          } else if (data.containsKey('detail')) {
            message = data['detail'].toString();
          } else {
            // Field-level DRF validation errors look like
            //   {"username": ["..."], "phone": ["..."]}.
            // Joining "<field>: <msg>" makes it obvious which input
            // failed — the previous code surfaced just "this field is
            // required" with no hint about which field.
            final lines = <String>[];
            data.forEach((field, value) {
              final msg = _firstString(value);
              if (msg.isNotEmpty) {
                lines.add(field == 'non_field_errors'
                    ? msg
                    : '$field: $msg');
              }
            });
            if (lines.isNotEmpty) message = lines.join('\n');
          }
        }

        return ServerFailure(errorMessage: message);
      case DioExceptionType.sendTimeout:
        return ServerFailure(
          errorMessage: S.current.sendTimeout,
        );
      case DioExceptionType.connectionError:
        return ServerFailure(errorMessage: S.current.connectionError);
      default:
        return ServerFailure(errorMessage: S.current.unexpectedError);
    }
  }

  static String _firstString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is List && v.isNotEmpty) return _firstString(v.first);
    return v.toString();
  }
}
