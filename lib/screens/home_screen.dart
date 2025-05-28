import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/traditional_auth_service.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_icon.dart';

class HomeScreen extends StatelessWidget {
  final User? user; // Para Firebase Auth
  final Map<String, dynamic>? userData; // Para auth tradicional
  final bool isTraditionalAuth;
  
  final AuthService authService = AuthService();

  HomeScreen({
    super.key,
    this.user,
    this.userData,
    required this.isTraditionalAuth,
  });

  String get displayName {
    if (isTraditionalAuth && userData != null) {
      // Intentar diferentes campos para el nombre
      return userData!['firstName']?.toString() ?? 
             userData!['username']?.toString() ?? 
             userData!['name']?.toString() ?? 
             'Usuario';
    } else if (user != null) {
      return user!.displayName ?? 'Usuario';
    }
    return 'Usuario';
  }

  String? get photoURL {
    if (isTraditionalAuth && userData != null) {
      return userData!['image']?.toString();
    } else if (user != null) {
      return user!.photoURL;
    }
    return null;
  }

  String get userInfo {
    if (isTraditionalAuth && userData != null) {
      return 'ID: ${userData!['id']} | Email: ${userData!['email'] ?? 'N/A'}';
    } else if (user != null) {
      return 'Email: ${user!.email ?? 'N/A'}';
    }
    return 'Sin información';
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      if (isTraditionalAuth) {
        await TraditionalAuthService.logout();
      } else {
        await authService.signOut();
      }
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  void _showUserInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información del Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: $displayName'),
            SizedBox(height: 8),
            Text('Tipo de sesión: ${isTraditionalAuth ? 'Tradicional' : 'Google'}'),
            SizedBox(height: 8),
            Text(userInfo),
            if (isTraditionalAuth && userData != null) ...[
              SizedBox(height: 8),
              Text('Token: ${userData!['token']?.toString().substring(0, 20) ?? 'N/A'}...'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: photoURL != null 
                ? NetworkImage(photoURL!) 
                : null,
              child: photoURL == null 
                ? Icon(Icons.person, size: 16) 
                : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola $displayName',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    isTraditionalAuth ? 'Sesión tradicional' : 'Sesión con Google',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CartIcon(
            onTap: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut(context);
              } else if (value == 'info') {
                _showUserInfo(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Info de usuario'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: AppTheme.secondaryDark,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.primaryDark,
        child: ProductListScreen(),
      ),
    );
  }
}
