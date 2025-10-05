import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'providers/user_provider.dart';
import 'providers/step_provider.dart';
import 'providers/badge_provider.dart';
import 'providers/social_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/analytics_provider.dart';
import 'screens/splash_screen.dart';
import 'services/fcm_service.dart';

// Handler pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📬 Message en arrière-plan: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configurer le handler pour les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const DizonliApp());
}

// Initialize app data after first login
Future<void> initializeAppData(BuildContext context) async {
  final badgeProvider = context.read<BadgeProvider>();
  
  // Initialize badges in Firestore (only once)
  try {
    await badgeProvider.initializeBadges();
  } catch (e) {
    debugPrint('Badge initialization error: $e');
  }
}

class DizonliApp extends StatelessWidget {
  const DizonliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StepProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('fr', 'FR'),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        initialRoute: '/',
        routes: AppRoutes.getRoutes(),
        home: const SplashScreen(),
      ),
    );
  }
}
