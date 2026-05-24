/// ============================================
/// FINTELIA — User Model
/// ============================================
library;

import 'package:equatable/equatable.dart';

/// User domain model.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.firebaseUid,
    this.riskTolerance = 'moderate',
    this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? firebaseUid;
  final String riskTolerance;
  final DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      firebaseUid: json['firebase_uid'] as String?,
      riskTolerance: json['risk_tolerance'] as String? ?? 'moderate',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'firebase_uid': firebaseUid,
        'risk_tolerance': riskTolerance,
      };

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? riskTolerance,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      firebaseUid: firebaseUid,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      createdAt: createdAt,
    );
  }

  /// Display name, falling back to email prefix.
  String get displayName => fullName ?? email.split('@').first;

  /// Initials for avatar placeholder.
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl];
}
