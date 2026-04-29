import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/loading_page.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Auth Service
  await AuthService.initialize();

  // Initialize Language Service
  await LanguageService.init();

  runApp(const SmartGrowApp());
}

class SmartGrowApp extends StatelessWidget {
  const SmartGrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.light, // Force light mode
        primaryColor: CupertinoColors.systemGreen,
        scaffoldBackgroundColor: CupertinoColors.white,
        barBackgroundColor: CupertinoColors.white,
      ),
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            if (settings.name == '/') {
              return const HomePage();
            }
            return const HomePage(); // Default fallback
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        print('AuthWrapper Debug: Auth state - connectionState: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, user: ${snapshot.data?.email}');
        
        // Show loading screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper Debug: Showing loading screen');
          return const LoadingPage();
        }

        // Show home page if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          print('AuthWrapper Debug: Showing home page for user: ${snapshot.data!.email}');
          return const HomePage();
        }

        // Show login page if user is not authenticated
        print('AuthWrapper Debug: Showing login page');
        return const LoginPage();
      },
    );
  }
}

