/// Punto de entrada principal de BeamReserve.
///
/// Configura flutter_dotenv, Supabase, y los Providers globales.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/websocket_manager.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/reservation_provider.dart';
import 'presentation/providers/requests_provider.dart';
import 'core/router/app_router.dart';

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
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create the provider instance once
    _authProvider = AuthProvider();
    // Create the router instance once, passing the provider
    _router = AppRouter.router(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => RequestsProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final wsUrl = dotenv.isInitialized
                ? (dotenv.maybeGet('WS_SERVER_URL') ?? '')
                : '';
            return WebSocketManager(url: wsUrl);
          },
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
