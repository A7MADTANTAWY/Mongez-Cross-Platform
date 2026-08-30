class AddressModel {
  final int? id;
  final String label;
  final String address;
  final String? governorate;
  final String? city;
  final bool isDefault;

  AddressModel({
    this.id,
    this.label = '',
    required this.address,
    this.governorate,
    this.city,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'address': address,
      if (governorate != null) 'governorate': governorate,
      if (city != null) 'city': city,
      'is_default': isDefault,
    };
  }

  String? get title => label.isEmpty ? null : label;

  /// Governorate, Area — used in Home screen and compact views.
  String get shortAddress {
    final parts = <String>[
      if ((city ?? '').isNotEmpty) city!,
      if ((governorate ?? '').isNotEmpty) governorate!,
    ];
    return parts.join(', ');
  }

  /// Full display: Label · Detailed Address · Area · Governorate
  String get displayAddress {
    final parts = <String>[
      if (label.isNotEmpty) label,
      address,
      if ((city ?? '').isNotEmpty) city!,
      if ((governorate ?? '').isNotEmpty) governorate!,
    ];
    return parts.join(' · ');
  }
}
