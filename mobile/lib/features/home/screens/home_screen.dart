import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/providers/influencer_provider.dart';
import '../../../core/models/influencer_profile.dart';
import '../widgets/search_bar.dart';
import '../widgets/influencer_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  InfluencerSearchParams _searchParams = const InfluencerSearchParams();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredInfluencers = ref.watch(featuredInfluencersProvider);
    final searchResults = ref.watch(influencerListProvider(_searchParams));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discover',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Find the perfect influencer for your brand',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showFilterBottomSheet(),
                        icon: Icon(
                          Icons.tune,
                          color: const Color(0xFF6366F1),
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CustomSearchBar(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    onFilterTap: _showFilterBottomSheet,
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Influencers
                    if (_searchController.text.isEmpty) ...[
                      Text(
                        'Featured Influencers',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      featuredInfluencers.when(
                        data: (influencers) => _buildFeaturedSection(influencers),
                        loading: () => _buildFeaturedLoading(),
                        error: (error, stack) => _buildErrorWidget(error.toString()),
                      ),
                      SizedBox(height: 32.h),
                    ],
                    
                    // Search Results or All Influencers
                    Text(
                      _searchController.text.isEmpty ? 'All Influencers' : 'Search Results',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    searchResults.when(
                      data: (influencers) => _buildInfluencerGrid(influencers),
                      loading: () => _buildGridLoading(),
                      error: (error, stack) => _buildErrorWidget(error.toString()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(List<InfluencerProfile> influencers) {
    if (influencers.isEmpty) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Text(
            'No featured influencers yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: influencers.length,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          final influencer = influencers[index];
          return _buildFeaturedCard(influencer);
        },
      ),
    );
  }

  Widget _buildFeaturedCard(InfluencerProfile influencer) {
    return GestureDetector(
      onTap: () => context.push('/influencer/${influencer.id}'),
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cover Image
            Container(
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            
            // Profile Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: influencer.profileImageUrl ?? 
                              'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF3F4F6),
                            child: Icon(
                              Icons.person,
                              color: const Color(0xFF9CA3AF),
                              size: 24.sp,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF3F4F6),
                            child: Icon(
                              Icons.person,
                              color: const Color(0xFF9CA3AF),
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // Name
                    Text(
                      influencer.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Followers
                    Text(
                      '${_formatNumber(influencer.totalFollowers)} followers',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Rating
                    if (influencer.rating != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFFFBBF24),
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            influencer.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfluencerGrid(List<InfluencerProfile> influencers) {
    if (influencers.isEmpty) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48.sp,
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(height: 16.h),
              Text(
                'No influencers found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                'Try adjusting your search filters',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: influencers.length,
      itemBuilder: (context, index) {
        return InfluencerCard(
          influencer: influencers[index],
          onTap: () => context.push('/influencer/${influencers[index].id}'),
        );
      },
    );
  }

  Widget _buildFeaturedLoading() {
    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) => _buildLoadingCard(),
      ),
    );
  }

  Widget _buildGridLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 16.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 12.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _searchParams = InfluencerSearchParams(
        query: query.isEmpty ? null : query,
        niches: _searchParams.niches,
        minFollowers: _searchParams.minFollowers,
        maxFollowers: _searchParams.maxFollowers,
        minEngagement: _searchParams.minEngagement,
        location: _searchParams.location,
      );
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentParams: _searchParams,
        onApply: (params) {
          setState(() {
            _searchParams = params;
          });
        },
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}