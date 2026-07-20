import 'package:equatable/equatable.dart';

import 'tokens.dart';
import 'user.dart';

class Auth extends Equatable {
  final String? message;
  final User? user;
  final Tokens? tokens;
  final bool? profileCompleted;
  final String? googlePictureUrl;
  final String? verificationStatus;

  const Auth({
    this.message,
    this.user,
    this.tokens,
    this.profileCompleted,
    this.googlePictureUrl,
    this.verificationStatus,
  });

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
    message: json['message'] as String?,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    tokens: json['tokens'] == null
        ? null
        : Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
    profileCompleted: json['profile_completed'] as bool?,
    googlePictureUrl: json['google_picture_url'] as String?,
    verificationStatus: json['verification_status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user?.toJson(),
    'tokens': tokens?.toJson(),
    'profile_completed': profileCompleted,
    'google_picture_url': googlePictureUrl,
    'verification_status': verificationStatus,
  };

  @override
  List<Object?> get props => [
        message,
        user,
        tokens,
        profileCompleted,
        googlePictureUrl,
        verificationStatus,
      ];
}
