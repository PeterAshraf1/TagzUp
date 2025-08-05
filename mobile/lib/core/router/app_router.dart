import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      return authState.when(
        initial: () => '/',
        loading: () => '/',
        authenticated: (user) {
          // If on auth screens, redirect to appropriate dashboard
          if (state.fullPath == '/login' || state.fullPath == '/register') {
            switch (user.userType) {
              case UserType.influencer:
                return '/influencer/dashboard';
              case UserType.business:
                return '/business/dashboard';
              case UserType.admin:
                return '/admin/dashboard';
            }
          }
          return null; // No redirect needed
        },
        unauthenticated: () {
          // If trying to access protected routes, redirect to login
          if (state.fullPath != '/login' && state.fullPath != '/register' && state.fullPath != '/') {
            return '/login';
          }
          return null;
        },
        error: (_) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/business/dashboard',
        builder: (context, state) => const HomeScreen(), // Placeholder
      ),
      GoRoute(
        path: '/influencer/dashboard',
        builder: (context, state) => const HomeScreen(), // Placeholder
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const HomeScreen(), // Placeholder
      ),
      GoRoute(
        path: '/influencer/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            appBar: AppBar(title: const Text('Influencer Details')),
            body: Center(child: Text('Influencer ID: $id')),
          ); // Placeholder
        },
      ),
    ],
  );
});