import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/influencer_profile.dart';
import '../models/social_account.dart';
import '../models/package.dart';
import '../services/api_service.dart';

final influencerListProvider = FutureProvider.family<List<InfluencerProfile>, InfluencerSearchParams>((ref, params) async {
  final apiService = ApiService();
  final response = await apiService.getInfluencers(
    query: params.query,
    niches: params.niches,
    minFollowers: params.minFollowers,
    maxFollowers: params.maxFollowers,
    minEngagement: params.minEngagement,
    location: params.location,
  );

  if (response.success && response.data != null) {
    return response.data!.map((json) => InfluencerProfile.fromJson(json)).toList();
  } else {
    throw Exception(response.error ?? 'Failed to load influencers');
  }
});

final featuredInfluencersProvider = FutureProvider<List<InfluencerProfile>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.getFeaturedInfluencers();

  if (response.success && response.data != null) {
    return response.data!.map((json) => InfluencerProfile.fromJson(json)).toList();
  } else {
    throw Exception(response.error ?? 'Failed to load featured influencers');
  }
});

final influencerDetailProvider = FutureProvider.family<InfluencerDetail, String>((ref, id) async {
  final apiService = ApiService();
  final response = await apiService.getInfluencer(id);

  if (response.success && response.data != null) {
    final data = response.data!;
    return InfluencerDetail(
      influencer: InfluencerProfile.fromJson(data['influencer']),
      socialAccounts: (data['social_accounts'] as List)
          .map((json) => SocialAccount.fromJson(json))
          .toList(),
      packages: (data['packages'] as List)
          .map((json) => Package.fromJson(json))
          .toList(),
    );
  } else {
    throw Exception(response.error ?? 'Failed to load influencer details');
  }
});

class InfluencerSearchParams {
  final String? query;
  final List<String>? niches;
  final int? minFollowers;
  final int? maxFollowers;
  final double? minEngagement;
  final String? location;

  const InfluencerSearchParams({
    this.query,
    this.niches,
    this.minFollowers,
    this.maxFollowers,
    this.minEngagement,
    this.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfluencerSearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          _listEquals(niches, other.niches) &&
          minFollowers == other.minFollowers &&
          maxFollowers == other.maxFollowers &&
          minEngagement == other.minEngagement &&
          location == other.location;

  @override
  int get hashCode =>
      query.hashCode ^
      (niches?.hashCode ?? 0) ^
      (minFollowers?.hashCode ?? 0) ^
      (maxFollowers?.hashCode ?? 0) ^
      (minEngagement?.hashCode ?? 0) ^
      (location?.hashCode ?? 0);

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

class InfluencerDetail {
  final InfluencerProfile influencer;
  final List<SocialAccount> socialAccounts;
  final List<Package> packages;

  const InfluencerDetail({
    required this.influencer,
    required this.socialAccounts,
    required this.packages,
  });
}