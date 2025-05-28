import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/traditional_auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
