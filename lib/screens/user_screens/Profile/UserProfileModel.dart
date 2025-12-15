// models/UserProfileModel.dart

class UserProfileModel {
  final int id;
  final String? username;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? mobile;
  final int? age;
  final String? gender;
  final String? image;
  final bool isRegister;
  final bool isProvider;
  final bool isBlocked;
  final String? referralCode;
  final String? referredBy;
  final double wallet;
  final bool emailVerified;
  final String createdAt;
  final String? updatedAt;
  final int? primaryAddressId;
  final bool? declaration;
  final ProviderModel? provider;

  UserProfileModel({
    required this.id,
    this.username,
    this.email,
    this.firstname,
    this.lastname,
    this.mobile,
    this.age,
    this.gender,
    this.image,
    required this.isRegister,
    required this.isProvider,
    required this.isBlocked,
    this.referralCode,
    this.referredBy,
    required this.wallet,
    required this.emailVerified,
    required this.createdAt,
    this.updatedAt,
    this.primaryAddressId,
    this.declaration,
    this.provider,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      username: json['username'],
      email: json['email'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      mobile: json['mobile'],
      age: json['age'],
      gender: json['gender'],
      image: json['image'],
      isRegister: json['isregister'] ?? false,
      isProvider: json['is_provider'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      referralCode: json['referral_code'],
      referredBy: json['referred_by'],
      wallet: (json['wallet'] ?? 0).toDouble(),
      emailVerified: json['email_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      primaryAddressId: json['primary_address_id'],
      declaration: json['declaration'],
      provider: json['provider'] != null
          ? ProviderModel.fromJson(json['provider'])
          : null,
    );
  }

  // Computed properties with null checks
  String get fullName {
    if (firstname != null && lastname != null) {
      return '$firstname $lastname';
    } else if (firstname != null) {
      return firstname!;
    } else if (lastname != null) {
      return lastname!;
    } else if (username != null) {
      return username!;
    } else if (mobile != null) {
      return mobile!;
    }
    return 'User';
  }

  String get displayEmail => email ?? 'Not provided';

  String get displayMobile => mobile ?? 'Not provided';

  String get displayImage => image ?? '';

  String get displayAddress => 'Not provided'; // Update when address is implemented

  bool get hasProviderData => provider != null;

  // Check if profile has basic information
  bool get hasBasicInfo =>
      firstname != null ||
          lastname != null ||
          username != null ||
          email != null;
}

class ProviderModel {
  final int id;
  final int userId;
  final bool isActive;
  final bool isRegistered;
  final double workRadius;
  final String? education;
  final String? adharNo;
  final String? panNo;
  final bool isBlocked;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.isRegistered,
    required this.workRadius,
    this.education,
    this.adharNo,
    this.panNo,
    required this.isBlocked,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      isActive: json['is_active'] ?? false,
      isRegistered: json['is_registered'] ?? false,
      workRadius: (json['work_radius'] ?? 0).toDouble(),
      education: json['education'],
      adharNo: json['adhar_no'],
      panNo: json['pan_no'],
      isBlocked: json['is_blocked'] ?? false,
    );
  }
}