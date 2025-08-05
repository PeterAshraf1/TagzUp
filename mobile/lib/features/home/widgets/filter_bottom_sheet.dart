import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/providers/influencer_provider.dart';
import '../../../core/constants/app_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final InfluencerSearchParams currentParams;
  final Function(InfluencerSearchParams) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentParams,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedNiches;
  late RangeValues _followersRange;
  late double _minEngagement;
  late String _location;

  final List<String> _availableNiches = [
    'Fashion', 'Beauty', 'Fitness', 'Food', 'Travel', 'Technology',
    'Gaming', 'Music', 'Art', 'Photography', 'Lifestyle', 'Business',
    'Education', 'Health', 'Sports', 'Entertainment'
  ];

  @override
  void initState() {
    super.initState();
    _selectedNiches = List.from(widget.currentParams.niches ?? []);
    _followersRange = RangeValues(
      (widget.currentParams.minFollowers ?? 0).toDouble(),
      (widget.currentParams.maxFollowers ?? 1000000).toDouble(),
    );
    _minEngagement = widget.currentParams.minEngagement ?? 0.0;
    _location = widget.currentParams.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Niches
                  _buildSectionTitle('Niches'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _availableNiches.map((niche) {
                      final isSelected = _selectedNiches.contains(niche);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedNiches.remove(niche);
                            } else {
                              _selectedNiches.add(niche);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            niche,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Followers Range
                  _buildSectionTitle('Followers'),
                  SizedBox(height: 12.h),
                  RangeSlider(
                    values: _followersRange,
                    min: 0,
                    max: 1000000,
                    divisions: 20,
                    labels: RangeLabels(
                      _formatNumber(_followersRange.start.round()),
                      _formatNumber(_followersRange.end.round()),
                    ),
                    activeColor: const Color(0xFF6366F1),
                    inactiveColor: const Color(0xFFE5E7EB),
                    onChanged: (values) {
                      setState(() {
                        _followersRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatNumber(_followersRange.start.round()),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        _formatNumber(_followersRange.end.round()),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Minimum Engagement Rate
                  _buildSectionTitle('Minimum Engagement Rate'),
                  SizedBox(height: 12.h),
                  Slider(
                    value: _minEngagement,
                    min: 0,
                    max: 20,
                    divisions: 40,
                    label: '${_minEngagement.toStringAsFixed(1)}%',
                    activeColor: const Color(0xFF6366F1),
                    inactiveColor: const Color(0xFFE5E7EB),
                    onChanged: (value) {
                      setState(() {
                        _minEngagement = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '20%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Location
                  _buildSectionTitle('Location'),
                  SizedBox(height: 12.h),
                  TextField(
                    onChanged: (value) => _location = value,
                    controller: TextEditingController(text: _location),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF1F2937),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          
          // Apply Button
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedNiches.clear();
      _followersRange = const RangeValues(0, 1000000);
      _minEngagement = 0.0;
      _location = '';
    });
  }

  void _applyFilters() {
    final params = InfluencerSearchParams(
      query: widget.currentParams.query,
      niches: _selectedNiches.isEmpty ? null : _selectedNiches,
      minFollowers: _followersRange.start.round() == 0 ? null : _followersRange.start.round(),
      maxFollowers: _followersRange.end.round() == 1000000 ? null : _followersRange.end.round(),
      minEngagement: _minEngagement == 0.0 ? null : _minEngagement,
      location: _location.isEmpty ? null : _location,
    );
    
    widget.onApply(params);
    Navigator.of(context).pop();
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