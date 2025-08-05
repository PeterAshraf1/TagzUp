import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/models/influencer_profile.dart';

class InfluencerCard extends StatelessWidget {
  final InfluencerProfile influencer;
  final VoidCallback onTap;

  const InfluencerCard({
    super.key,
    required this.influencer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Profile Image Overlay
            Stack(
              children: [
                Container(
                  height: 80.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                
                // Featured Badge
                if (influencer.isFeatured)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                
                // Profile Image
                Positioned(
                  bottom: -25.h,
                  left: 12.w,
                  child: Container(
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
                ),
              ],
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 30.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Verification
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            influencer.displayName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (influencer.verificationStatus == VerificationStatus.verified)
                          Icon(
                            Icons.verified,
                            color: const Color(0xFF10B981),
                            size: 16.sp,
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Location
                    if (influencer.location != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: const Color(0xFF6B7280),
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              influencer.location!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    
                    SizedBox(height: 8.h),
                    
                    // Followers and Engagement
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatNumber(influencer.totalFollowers),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (influencer.avgEngagementRate != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${influencer.avgEngagementRate!.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  'Engagement',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Rating and Reviews
                    if (influencer.rating != null)
                      Row(
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
                          SizedBox(width: 4.w),
                          Text(
                            '(${influencer.totalReviews})',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
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