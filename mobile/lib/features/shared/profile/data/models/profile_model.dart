import 'package:equatable/equatable.dart';
import 'package:mongez/features/auth/models/user.dart';

class ProfileModel extends Equatable {
  final int id;
  final String username;
  final String? email;
  final String? nameAr;
  final String? displayName;
  final String phone;
  final String address;
  final String? governorate;
  final String? governorateLabel;
  final String? city;
  final String? profileImage;
  final String role;
  final String? dateJoined;
  final bool? profileCompleted;
  final String? verificationStatus;
  final String? rejectionReason;
  final int? workerId;
  final int? experienceYears;
  final double? averageRating;
  final int? completedJobs;
  final bool? isAvailable;
  final int? categoryId;
  final String? categoryName;

  const ProfileModel({
    required this.id,
    required this.username,
    this.email,
    this.nameAr,
    this.displayName,
    required this.phone,
    this.address = '',
    this.governorate,
    this.governorateLabel,
    this.city,
    this.profileImage,
    this.role = 'client',
    this.dateJoined,
    this.profileCompleted,
    this.verificationStatus,
    this.rejectionReason,
    this.workerId,
    this.experienceYears,
    this.averageRating,
    this.completedJobs,
    this.isAvailable,
    this.categoryId,
    this.categoryName,
  });

  factory ProfileModel.fromUser(User user) {
    return ProfileModel(
      id: user.id ?? 0,
      username: user.username ?? '',
      email: user.email,
      nameAr: user.nameAr,
      displayName: user.displayName,
      phone: user.phone ?? '',
      address: user.address ?? '',
      governorate: user.governorate,
      governorateLabel: user.governorateLabel,
      city: user.city,
      profileImage: user.profileImage,
      role: user.role ?? 'client',
      dateJoined: user.dateJoined?.toIso8601String(),
      profileCompleted: user.profileCompleted,
      verificationStatus: user.verificationStatus,
      rejectionReason: user.rejectionReason,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      nameAr: json['name_ar'] as String?,
      displayName: json['display_name'] as String?,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      governorate: json['governorate'] as String?,
      governorateLabel: json['governorate_label'] as String?,
      city: json['city'] as String?,
      profileImage: (json['avatar_url'] ?? json['profile_image']) as String?,
      role: json['role'] as String? ?? 'client',
      dateJoined: json['date_joined'] as String?,
      profileCompleted: json['profile_completed'] as bool?,
      verificationStatus: json['verification_status'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      completedJobs: json['completed_jobs'] as int?,
      workerId: json['worker_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'phone': phone,
    'address': address,
  };

  ProfileModel copyWith({
    String? username,
    String? phone,
    String? address,
    String? profileImage,
    String? verificationStatus,
    String? rejectionReason,
    int? workerId,
    int? experienceYears,
    double? averageRating,
    int? completedJobs,
    bool? isAvailable,
    int? categoryId,
    String? categoryName,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      nameAr: nameAr,
      displayName: displayName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      governorate: governorate,
      governorateLabel: governorateLabel,
      city: city,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      dateJoined: dateJoined,
      profileCompleted: profileCompleted,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      workerId: workerId ?? this.workerId,
      experienceYears: experienceYears ?? this.experienceYears,
      averageRating: averageRating ?? this.averageRating,
      completedJobs: completedJobs ?? this.completedJobs,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [
    id, username, nameAr, displayName, phone, address,
    governorate, governorateLabel, city, profileImage, role,
    dateJoined, profileCompleted, verificationStatus, rejectionReason,
    workerId, experienceYears, averageRating,
    completedJobs, isAvailable, categoryId, categoryName,
  ];
}
