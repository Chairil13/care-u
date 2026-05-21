import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/motorcycle_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/teknisi_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/story_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/user_main_screen.dart';
import 'screens/teknisi/teknisi_main_screen.dart';
import 'screens/admin/admin_home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase successfully initialized on startup');
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const CareUApp());
}

class CareUApp extends StatelessWidget {
  const CareUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MotorcycleProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => TeknisiProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: MaterialApp(
        title: 'CareU - Motor Care Companion',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD9614C),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        home: const SplashRouter(),
      ),
    );
  }
}

/// Router yang mengecek session saat startup
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final auth = context.read<AuthProvider>();
    await auth.checkCurrentSession();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Tampilkan splash saat loading awal (HANYA jika belum terautentikasi)
        if (auth.isLoading && !auth.isAuthenticated) {
          return const SplashScreen();
        }

        // Jika sudah login, route ke halaman sesuai role
        if (auth.isAuthenticated && auth.currentUser != null) {
          final user = auth.currentUser!;
          if (user.isAdmin) return const AdminHomeScreen();
          if (user.isTeknisi) return const TeknisiMainScreen();
          return const UserMainScreen();
        }

        // Belum login → Login Screen
        return const LoginScreen();
      },
    );
  }
}

/// Splash screen saat app pertama kali dibuka
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9614C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2C1810),
                      width: 4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(8, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.motorcycle_rounded,
                    color: Color(0xFFF4EBD0),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 48),
                // App Name
                Text(
                  'CARE-U',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C1810),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5B94C),
                  ),
                  child: Text(
                    'MOTOR CARE COMPANION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C1810),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                // Retro Loading Indicator
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Color(0xFF2C1810),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
