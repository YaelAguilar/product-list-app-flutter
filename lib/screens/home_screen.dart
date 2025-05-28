import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final AuthService authService = AuthService();

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: user.photoURL != null 
                ? NetworkImage(user.photoURL!) 
                : null,
              child: user.photoURL == null 
                ? Icon(Icons.person, size: 16) 
                : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hola ${user.displayName ?? 'Usuario'}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
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
      ),
      body: ProductListScreen(),
    );
  }
}