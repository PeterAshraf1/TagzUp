import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  late final FlutterSecureStorage _storage;
  late final Logger _logger;

  void initialize() {
    _storage = const FlutterSecureStorage();
    _logger = Logger();
    
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        _logger.d('${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('API Error: ${error.message}');
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - clear token and redirect to login
          _storage.delete(key: AppConstants.tokenKey);
          _storage.delete(key: AppConstants.userKey);
        }
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String userType,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'user_type': userType,
        if (phone != null) 'phone': phone,
      });

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Influencer endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getInfluencers({
    String? query,
    List<String>? niches,
    int? minFollowers,
    int? maxFollowers,
    double? minEngagement,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['query'] = query;
      if (niches != null && niches.isNotEmpty) queryParams['niches'] = niches;
      if (minFollowers != null) queryParams['min_followers'] = minFollowers.toString();
      if (maxFollowers != null) queryParams['max_followers'] = maxFollowers.toString();
      if (minEngagement != null) queryParams['min_engagement'] = minEngagement.toString();
      if (location != null) queryParams['location'] = location;

      final response = await _dio.get('/influencers', queryParameters: queryParams);
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getInfluencer(String id) async {
    try {
      final response = await _dio.get('/influencers/$id');
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getFeaturedInfluencers() async {
    try {
      final response = await _dio.get('/influencers/featured');
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Booking endpoints
  Future<ApiResponse<Map<String, dynamic>>> createBooking({
    required String packageId,
    String? brief,
    String? requirements,
    DateTime? deadline,
  }) async {
    try {
      final response = await _dio.post('/bookings', data: {
        'package_id': packageId,
        if (brief != null) 'brief': brief,
        if (requirements != null) 'requirements': requirements,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
      });

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBookings() async {
    try {
      final response = await _dio.get('/bookings');
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getBooking(String id) async {
    try {
      final response = await _dio.get('/bookings/$id');
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null && error.response!.data['error'] != null) {
      return error.response!.data['error'];
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}