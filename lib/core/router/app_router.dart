library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/register/register_screen.dart';
import '../../presentation/screens/register/additional_user_data_screen.dart';
import '../../presentation/screens/reservation/reservation_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToSplash = state.matchedLocation == '/splash';
        final hasAdditionalData = authProvider.hasAdditionalData; // We need to implement this
        final isGoingToAdditionalData = state.matchedLocation == '/additional-data';

        if (isGoingToSplash) {
          // Splash screen handles its own navigation after animation/initialization
          return null;
        }

        if (!isAuthenticated) {
          if (!isGoingToLogin && !isGoingToRegister) {
            return '/login';
          }
          return null;
        }

        if (isAuthenticated) {
          // If authenticated but missing additional data, force them to additional data screen
          if (!hasAdditionalData && !isGoingToAdditionalData) {
             return '/additional-data';
          }
          
          if (isGoingToLogin || isGoingToRegister || isGoingToSplash) {
            return hasAdditionalData ? '/' : '/additional-data';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
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
          path: '/additional-data',
          builder: (context, state) => const AdditionalUserDataScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/reservation',
          builder: (context, state) => const ReservationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}
