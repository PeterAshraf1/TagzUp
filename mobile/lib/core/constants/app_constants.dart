class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:4000/api';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  
  // App Configuration
  static const String appName = 'TagzUp';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Social Media Platforms
  static const List<String> supportedPlatforms = [
    'instagram',
    'tiktok', 
    'youtube',
    'facebook',
    'twitter',
    'linkedin'
  ];
  
  // User Types
  static const String influencerType = 'influencer';
  static const String businessType = 'business';
  static const String adminType = 'admin';
  
  // Booking Status
  static const Map<String, String> bookingStatusLabels = {
    'pending_payment': 'Pending Payment',
    'paid': 'Paid',
    'in_progress': 'In Progress',
    'pending_proof': 'Pending Proof',
    'pending_verification': 'Pending Verification',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'disputed': 'Disputed',
  };
  
  // Colors
  static const Map<String, int> statusColors = {
    'pending': 0xFFF59E0B,
    'verified': 0xFF10B981,
    'rejected': 0xFFEF4444,
    'failed': 0xFFEF4444,
    'completed': 0xFF10B981,
    'cancelled': 0xFF6B7280,
    'disputed': 0xFFEF4444,
  };
}