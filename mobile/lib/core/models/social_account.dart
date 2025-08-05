import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_account.freezed.dart';
part 'social_account.g.dart';

@freezed
class SocialAccount with _$SocialAccount {
  const factory SocialAccount({
    required String id,
    required String influencerProfileId,
    required SocialPlatform platform,
    required String username,
    required String profileUrl,
    @Default(0) int followerCount,
    double? engagementRate,
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
    DateTime? lastVerifiedAt,
    Map<String, dynamic>? apiData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SocialAccount;

  factory SocialAccount.fromJson(Map<String, dynamic> json) => 
      _$SocialAccountFromJson(json);
}

@JsonEnum()
enum SocialPlatform {
  @JsonValue('instagram')
  instagram,
  @JsonValue('tiktok')
  tiktok,
  @JsonValue('youtube')
  youtube,
  @JsonValue('facebook')
  facebook,
  @JsonValue('twitter')
  twitter,
  @JsonValue('linkedin')
  linkedin,
}

@JsonEnum()
enum VerificationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('failed')
  failed,
}