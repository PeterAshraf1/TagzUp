import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Search influencers...',
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF6B7280),
            size: 20.sp,
          ),
          suffixIcon: IconButton(
            onPressed: onFilterTap,
            icon: Icon(
              Icons.tune,
              color: const Color(0xFF6366F1),
              size: 20.sp,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }
}