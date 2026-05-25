/// Punto de entrada principal de BeamReserve.
///
/// Configura flutter_dotenv, Supabase, y los Providers globales.
/// Arquitectura Clean Architecture con patrón Feature-First.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/services/notification/notification_service.dart';
import 'core/services/notification/notification_service_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/reservation_provider.dart';
import 'presentation/providers/requests_provider.dart';
import 'core/router/app_router.dart';

// Clean Architecture imports - Feature-First
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/storage_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/storage_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/storage_repository.dart';
import 'features/reservations/data/datasources/reservation_remote_datasource.dart';
import 'features/reservations/data/repositories/reservation_repository_impl.dart';
import 'features/reservations/domain/repositories/reservation_repository.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/requests/data/datasources/requests_remote_datasource.dart';
import 'features/requests/data/repositories/requests_repository_impl.dart';
import 'features/requests/domain/repositories/requests_repository.dart';
import 'features/users_management/data/datasources/users_remote_datasource.dart';
import 'features/users_management/data/repositories/user_management_repository_impl.dart';
import 'features/users_management/domain/repositories/i_user_management_repository.dart';
import 'features/users_management/presentation/providers/user_management_provider.dart';

// View Reservation Calendar imports
import 'features/view_reservation_calendar/data/datasources/view_reservation_calendar_remote_datasource.dart';
import 'features/view_reservation_calendar/data/repositories/view_reservation_calendar_repository_impl.dart';
import 'features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';
import 'presentation/providers/view_reservation_calendar_provider.dart';

late final NotificationService notificationService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // 1. Inicializar Firebase (OBLIGATORIO antes de usar cualquier servicio de Firebase)
  await Firebase.initializeApp();

  // 2. Inicializar el servicio de notificaciones
  notificationService = NotificationServiceImpl();
  await notificationService.initialize();

  // 3. Obtener el token FCM y guardarlo en Supabase
  final token = await notificationService.getDeviceToken();
  if (token != null) {
    // Guardar el token en la tabla 'profiles' de Supabase
    // await supabaseClient.from('profiles').update({'fcm_token': token}).eq('id', userId);
  }
  // Load environment variables (gracefully handle errors in test environments)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // In test environments or when .env is not available, continue with empty env
    debugPrint('Warning: Could not load .env file: $e');
  }

  // Initialize date formatting for Spanish locale
  await initializeDateFormatting('es', null);

  // Get environment variables safely (works even if dotenv failed to load)
  final supabaseUrl = dotenv.isInitialized
      ? (dotenv.maybeGet('SUPABASE_URL') ?? '')
      : '';
  final supabaseAnonKey = dotenv.isInitialized
      ? (dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '')
      : '';

  // Initialize Firebase (for FCM push notifications)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Warning: Firebase initialization failed: $e');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BeamReserveApp());
}

class BeamReserveApp extends StatefulWidget {
  const BeamReserveApp({super.key});

  @override
  State<BeamReserveApp> createState() => _BeamReserveAppState();
}

class _BeamReserveAppState extends State<BeamReserveApp> {
  late final GoRouter _router;
  late final AuthProvider _authProvider;
  late final NotificationService _notificationService;

  // Clean Architecture: Repositories
  late final AuthRepository _authRepository;
  late final StorageRepository _storageRepository;
  late final ReservationRepository _reservationRepository;
  late final DashboardRepository _dashboardRepository;
  late final RequestsRepository _requestsRepository;
  late final IUserManagementRepository _usersManagementRepository;
  late final ViewReservationCalendarRepository _viewReservationCalendarRepository;

  @override
  void initState() {
    super.initState();

    // Initialize Supabase client
    final supabaseClient = Supabase.instance.client;

    // Clean Architecture: Initialize Data Sources
    final authRemoteDataSource = AuthRemoteDataSource(supabaseClient);
    final storageRemoteDataSource = StorageRemoteDataSource(supabaseClient);
    final reservationRemoteDataSource = ReservationRemoteDataSource(
      supabaseClient,
    );
    final dashboardRemoteDataSource = DashboardRemoteDataSource(supabaseClient);
    final requestsRemoteDataSource = RequestsRemoteDataSource(supabaseClient);
    final usersRemoteDataSource = UsersRemoteDataSource(supabaseClient);
    final viewReservationCalendarRemoteDataSource = ViewReservationCalendarRemoteDataSource(supabaseClient);

    // Clean Architecture: Initialize Repositories
    _authRepository = AuthRepositoryImpl(authRemoteDataSource);
    _storageRepository = StorageRepositoryImpl(storageRemoteDataSource);
    _reservationRepository = ReservationRepositoryImpl(
      reservationRemoteDataSource,
    );
    _dashboardRepository = DashboardRepositoryImpl(
      dashboardRemoteDataSource,
      supabaseClient,
    );
    _requestsRepository = RequestsRepositoryImpl(requestsRemoteDataSource);
    _usersManagementRepository = UserManagementRepositoryImpl(
      usersRemoteDataSource,
    );
    _viewReservationCalendarRepository = ViewReservationCalendarRepositoryImpl(
      viewReservationCalendarRemoteDataSource,
    );

    // Initialize Notification service (FCM push notifications)
    _notificationService = NotificationServiceImpl();
    try {
      _notificationService.initialize(); // fire-and-forget: permisos, canales, listeners
    } catch (e) {
      debugPrint('Warning: NotificationService.initialize() failed: $e');
    }

    // Create SINGLE AuthProvider instance (shared by router AND UI)
    _authProvider = AuthProvider(_authRepository, _storageRepository, _notificationService);

    // Create the router instance once, passing the SAME auth provider
    _router = AppRouter.router(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Clean Architecture: Provide repositories to the widget tree
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<StorageRepository>.value(value: _storageRepository),
        Provider<ReservationRepository>.value(value: _reservationRepository),
        Provider<DashboardRepository>.value(value: _dashboardRepository),
        Provider<RequestsRepository>.value(value: _requestsRepository),
        Provider<IUserManagementRepository>.value(
          value: _usersManagementRepository,
        ),
        Provider<ViewReservationCalendarRepository>.value(
          value: _viewReservationCalendarRepository,
        ),

        // Existing providers (refactored to use repositories)
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(_dashboardRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservationProvider(_reservationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RequestsProvider(_requestsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(_usersManagementRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ViewReservationCalendarProvider(_viewReservationCalendarRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'BeamReserve',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        locale: const Locale('es'),
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
