/// Punto de entrada principal de BeamReserve.
///
/// Configura flutter_dotenv, Supabase, y los Providers globales.
/// Arquitectura Clean Architecture con patrón Feature-First.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
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
import 'features/auth/domain/use_cases/upload_profile_photo_use_case.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Clean Architecture: Repositories
  late final AuthRepository _authRepository;
  late final StorageRepository _storageRepository;
  late final ReservationRepository _reservationRepository;
  late final DashboardRepository _dashboardRepository;
  late final RequestsRepository _requestsRepository;
  late final IUserManagementRepository _usersManagementRepository;

  // Use Cases
  late final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;

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

    // Initialize Use Cases
    _uploadProfilePhotoUseCase = UploadProfilePhotoUseCase(_storageRepository);

    // Create the router instance once, passing the auth provider
    _router = AppRouter.router(AuthProvider(_authRepository, _storageRepository));
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

        // Existing providers (refactored to use repositories)
        ChangeNotifierProvider(create: (_) => AuthProvider(_authRepository, _storageRepository)),
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
      ],
      child: MaterialApp.router(
        title: 'BeamReserve',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
