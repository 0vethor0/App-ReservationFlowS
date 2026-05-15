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
import '../../presentation/screens/auth/waiting_approval_screen.dart';
import '../../presentation/screens/admin/user_approvals_screen.dart';
import '../../features/auth/domain/entities/user_entity.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final matchedLocation = state.matchedLocation; // Simplificamos acceso
      
      // 1. PRIORIDAD: Si es un callback de OAuth, NO INTERVENIR.
      // Esto permite que el AuthProvider procese el token internamente.
      if (matchedLocation.contains('callback')) {
        return null; 
      }

      final isGoingToLogin = matchedLocation == '/login';
      final isGoingToRegister = matchedLocation == '/register';
      final isGoingToSplash = matchedLocation == '/splash';
      
      // Pantalla de carga inicial
      if (isGoingToSplash) return null;

      // 2. MANEJO DE NO AUTENTICADOS
      if (!isAuthenticated) {
        // CORRECCIÓN: Si no está autenticado, solo permitir login o registro.
        // Agregamos seguridad para no redirigir si ya estamos en una de esas rutas.
        if (!isGoingToLogin && !isGoingToRegister) {
          return '/login';
        }
        return null;
      }

      // 3. MANEJO DE AUTENTICADOS
      if (isAuthenticated) {
        final hasAdditionalData = authProvider.hasAdditionalData;
        final userStatus = authProvider.currentUserStatus;
        final isGoingToAdditionalData = matchedLocation == '/additional-data';
        final isGoingToWaiting = matchedLocation == '/waiting';

        // Si falta información de perfil (como en registros nuevos de Google)
        if (!hasAdditionalData && !isGoingToAdditionalData) {
          return '/additional-data';
        }

        // Verificación de aprobación (Waiting Approval)
        if (hasAdditionalData && userStatus != null) {
          if ((userStatus == UserStatus.pending || userStatus == UserStatus.rejected) && !isGoingToWaiting) {
            return '/waiting';
          }
          if (userStatus == UserStatus.approved && isGoingToWaiting) {
            return '/';
          }
        }

        // Si ya está todo en orden y trata de entrar a login/register/splash -> al Dashboard
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
        GoRoute(
          path: '/waiting',
          builder: (context, state) => const WaitingApprovalScreen(),
        ),
        GoRoute(
          path: '/admin/user-approvals',
          builder: (context, state) => const UserApprovalsScreen(),
        ),
      ],
    );
  }
}
