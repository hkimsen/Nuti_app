import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/root.dart';
import 'screens/get_started.dart';
import 'screens/auth_screen.dart';
import 'screens/personal_info_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi'); // 🔥 bắt buộc
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutrition App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD1C4E9), // tím pastel
          primary: const Color(0xFFD1C4E9),
          secondary: const Color(0xFFC8E6C9), // xanh lá pastel
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        useMaterial3: true,
      ),
      home: const GetStartedScreen(),
      routes: {
        '/get-started': (_) => const GetStartedScreen(),
        '/auth': (ctx) => const AuthScreen(initialTab: 0),
        '/auth-signup': (ctx) => const AuthScreen(initialTab: 1),
        '/personal-info': (_) => const PersonalInfoScreen(),
        '/home': (_) => const Root(),
      },
      locale: const Locale('vi'),
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      // Not logged in
      Navigator.of(context).pushReplacementNamed('/get-started');
    } else {
      // Check if has personal info
      final height = prefs.getDouble('height');
      if (height == null) {
        // Needs to fill personal info
        Navigator.of(context).pushReplacementNamed('/personal-info');
      } else {
        // Has everything, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 80, color: Color(0xFFD1C4E9)),
            const SizedBox(height: 20),
            const Text(
              "Nuti Health",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}