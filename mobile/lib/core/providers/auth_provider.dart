import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../constants/app_constants.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      final userJson = await _storage.read(key: AppConstants.userKey);
      
      if (token != null && userJson != null) {
        final user = User.fromJson(json.decode(userJson));
        
        // Verify token is still valid
        final response = await _apiService.getCurrentUser();
        if (response.success) {
          state = AuthState.authenticated(user);
        } else {
          await _clearAuthData();
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      await _clearAuthData();
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String userType,
    String? phone,
  }) async {
    state = const AuthState.loading();
    
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        userType: userType,
        phone: phone,
      );

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!['user']);
        final token = response.data!['token'];
        
        await _saveAuthData(user, token);
        state = AuthState.authenticated(user);
        return true;
      } else {
        state = AuthState.error(response.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      state = AuthState.error('Registration failed: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!['user']);
        final token = response.data!['token'];
        
        await _saveAuthData(user, token);
        state = AuthState.authenticated(user);
        return true;
      } else {
        state = AuthState.error(response.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      state = AuthState.error('Login failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    state = const AuthState.unauthenticated();
  }

  Future<void> _saveAuthData(User user, String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(key: AppConstants.userKey, value: json.encode(user.toJson()));
  }

  Future<void> _clearAuthData() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}