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
import 'package:provider/provider.dart';
import '../../features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';
import '../../presentation/providers/reservation_calendar_provider.dart';
import '../../presentation/screens/reservation/reservation_calendar_view.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoadingAdditionalData = authProvider.isLoadingAdditionalData;
        final hasAdditionalData = authProvider.hasAdditionalData;
        final userStatus = authProvider.currentUserStatus;
        final matchedLocation = state.matchedLocation;

        debugPrint(
          '[${DateTime.now()}] [ROUTER] Evaluando redirect, pagina actual: → $matchedLocation | auth: $isAuthenticated | loadingData: $isLoadingAdditionalData | hasData: $hasAdditionalData',
        );

        // 1. OAuth Callback - No intervenir
        if (matchedLocation.contains('callback')) {
          return null;
        }

        final isGoingToLogin = matchedLocation == '/login';
        final isGoingToRegister = matchedLocation == '/register';
        final isGoingToSplash = matchedLocation == '/splash';
        final isGoingToAdditionalData = matchedLocation == '/additional-data';
        final isGoingToWaiting = matchedLocation == '/waiting';

        // Pantalla de carga inicial
        if (isGoingToSplash) return null;

        // 2. MANEJO DE NO AUTENTICADOS
        if (!isAuthenticated) {
          if (!isGoingToLogin && !isGoingToRegister) {
            return '/login';
          }
          return null;
        }

        // 3. MANEJO DE AUTENTICADOS
        if (isAuthenticated) {
          // === RACE CONDITION FIX: Esperar a que termine la verificación ===
          if (isLoadingAdditionalData) {
            debugPrint(
              '[${DateTime.now()}] [ROUTER] Aún cargando datos adicionales → esperando',
            );
            return null; // No redirigir hasta tener resultado
          }

          if (hasAdditionalData && isGoingToAdditionalData) {
            debugPrint(
              '[ROUTER] Ya tiene datos adicionales → redirigiendo a dashboard',
            );
            return '/waiting';
          }

          // Redirección a datos adicionales
          if (!hasAdditionalData && !isGoingToAdditionalData) {
            debugPrint(
              '[${DateTime.now()}] [ROUTER] Redirigiendo a additional-data',
            );
            return '/additional-data';
          }

          // Verificación de aprobación (Waiting Approval)
          if (hasAdditionalData && userStatus != null) {
            if ((userStatus == UserStatus.pending ||
                    userStatus == UserStatus.rejected) &&
                !isGoingToWaiting) {
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

          // Verificación de acceso a la pantalla de solicitudes (solo super_admin)
          if (matchedLocation == '/admin/user-approvals') {
            final userRole = authProvider.currentUser?.role;
            if (userRole != UserRole.superAdmin) {
              return '/';
            }
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
        GoRoute(
          path: '/reservation-calendar',
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (ctx) => ReservationCalendarProvider(
                ctx.read<ViewReservationCalendarRepository>(),
              ),
              child: const ReservationCalendarView(),
            );
          },
        ),
        GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      ],
    );
  }
}
