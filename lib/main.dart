import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/traditional_auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'screens/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neo Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: {
        '/cart': (context) => CartScreen(),
      },
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.primaryDark,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGreen,
                          AppTheme.accentGreenDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: AppTheme.primaryDark,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return snapshot.data ?? LoginScreen();
      },
    );
  }

  Future<Widget> _determineInitialScreen() async {
    // Verificar sesión de Firebase
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return HomeScreen(user: firebaseUser, isTraditionalAuth: false);
    }

    // Verificar sesión tradicional
    final hasTraditionalSession = await TraditionalAuthService.hasActiveSession();
    if (hasTraditionalSession) {
      final userData = await TraditionalAuthService.getUserData();
      if (userData != null) {
        return HomeScreen(userData: userData, isTraditionalAuth: true);
      }
    }

    return LoginScreen();
  }
}
