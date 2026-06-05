/// Punto de entrada principal de BeamReserve.
///
/// Configura flutter_dotenv, Supabase, y los Providers globales.
/// Arquitectura Clean Architecture con patrón Feature-First.
library;

import 'package:beam_reserve/presentation/providers/version_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PlatformDispatcher;
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
import 'features/products/data/datasources/products_remote_datasource.dart';
import 'features/products/data/repositories/products_repository_impl.dart';
import 'features/products/domain/repositories/i_products_repository.dart';

// View Reservation Calendar imports
import 'features/view_reservation_calendar/data/datasources/view_reservation_calendar_remote_datasource.dart';
import 'features/view_reservation_calendar/data/repositories/view_reservation_calendar_repository_impl.dart';
import 'features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';
import 'presentation/providers/view_reservation_calendar_provider.dart';

// Messaging imports
import 'features/messaging/data/datasources/messaging_remote_datasource.dart';
import 'features/messaging/data/repositories/messaging_repository_impl.dart';
import 'features/messaging/domain/repositories/i_messaging_repository.dart';
import 'features/messaging/presentation/providers/messaging_provider.dart';

late final NotificationService notificationService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };

  try {
    await _initializeApp();
  } catch (e, st) {
    debugPrint('Fatal initialization error: $e\n$st');
    runApp(InitErrorApp(error: e.toString()));
    return;
  }
  runApp(const BeamReserveApp());
}

Future<void> _initializeApp() async {
  await Firebase.initializeApp();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  await initializeDateFormatting('es', null);

  final supabaseUrl = dotenv.isInitialized
      ? (dotenv.maybeGet('SUPABASE_URL') ?? '')
      : '';
  final supabaseAnonKey = dotenv.isInitialized
      ? (dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '')
      : '';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  notificationService = NotificationServiceImpl();
  await notificationService.initialize();

  final token = await notificationService.getDeviceToken();
  if (token != null) {
    // await supabaseClient.from('profiles').update({'fcm_token': token}).eq('id', userId);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class InitErrorApp extends StatelessWidget {
  final String error;
  const InitErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeamReserve',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F1923),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error de inicialización',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Cerrar aplicación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
  late final ViewReservationCalendarRepository
  _viewReservationCalendarRepository;
  late final IMessagingRepository _messagingRepository;
  late final IProductsRepository _productsRepository;

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
    final viewReservationCalendarRemoteDataSource =
        ViewReservationCalendarRemoteDataSource(supabaseClient);
    final messagingRemoteDataSource = MessagingRemoteDataSource(supabaseClient);
    final productsRemoteDataSource = ProductsRemoteDataSource(supabaseClient);

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
    _messagingRepository = MessagingRepositoryImpl(messagingRemoteDataSource);
    _productsRepository = ProductsRepositoryImpl(productsRemoteDataSource);

    // Initialize Notification service (FCM push notifications)
    _notificationService = NotificationServiceImpl();
    try {
      _notificationService
          .initialize(); // fire-and-forget: permisos, canales, listeners
    } catch (e) {
      debugPrint('Warning: NotificationService.initialize() failed: $e');
    }

    // Create SINGLE AuthProvider instance (shared by router AND UI)
    _authProvider = AuthProvider(
      _authRepository,
      _storageRepository,
      _notificationService,
    );

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
        Provider<IMessagingRepository>.value(value: _messagingRepository),
        Provider<IProductsRepository>.value(value: _productsRepository),

        // Existing providers (refactored to use repositories)
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(_dashboardRepository),
        ),
        ChangeNotifierProvider(create: (_) => VersionUpdateProvider()),
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
          create: (_) => ViewReservationCalendarProvider(
            _viewReservationCalendarRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MessagingProvider(_messagingRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'BeamReserve',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
