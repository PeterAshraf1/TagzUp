import 'package:freezed_annotation/freezed_annotation.dart';

part 'influencer_profile.freezed.dart';
part 'influencer_profile.g.dart';

@freezed
class InfluencerProfile with _$InfluencerProfile {
  const factory InfluencerProfile({
    required String id,
    required String displayName,
    String? bio,
    String? profileImageUrl,
    String? coverImageUrl,
    String? location,
    @Default([]) List<String> languages,
    @Default([]) List<String> niches,
    @Default(0) int totalFollowers,
    double? avgEngagementRate,
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
    @Default(false) bool isFeatured,
    double? rating,
    @Default(0) int totalReviews,
    @Default(0) int totalBookings,
    @Default(0.0) double earnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _InfluencerProfile;

  factory InfluencerProfile.fromJson(Map<String, dynamic> json) => 
      _$InfluencerProfileFromJson(json);
}

@JsonEnum()
enum VerificationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
}