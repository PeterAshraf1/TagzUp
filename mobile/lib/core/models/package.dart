import 'package:freezed_annotation/freezed_annotation.dart';
import 'social_account.dart';

part 'package.freezed.dart';
part 'package.g.dart';

@freezed
class Package with _$Package {
  const factory Package({
    required String id,
    required String influencerProfileId,
    required String title,
    String? description,
    required List<SocialPlatform> platforms,
    required List<String> deliverables,
    required double price,
    @Default('EGP') String currency,
    required int deliveryTimeDays,
    @Default(1) int revisionsIncluded,
    int? postDurationHours,
    @Default(true) bool isActive,
    String? requirements,
    @Default([]) List<String> sampleWorkUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Package;

  factory Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);
}