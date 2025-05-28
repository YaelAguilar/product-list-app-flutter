import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/traditional_auth_service.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final userController = TextEditingController();
  final passController = TextEditingController();
  
  String error = '';
  String success = '';
  bool _isLoading = false;
  bool _showTraditionalLogin = false;
  int _selectedUserIndex = 0;
  bool _obscurePassword = true;

  // Lista de usuarios masculinos que funcionan realmente
  final List<Map<String, String>> _availableUsers = [
    {
      'username': 'michaelw', 
      'password': 'michaelwpass', 
      'name': 'Michael Williams',
      'description': 'Desarrollador de Software'
    },
    {
      'username': 'jamesd', 
      'password': 'jamesdpass', 
      'name': 'James Davis',
      'description': 'Diseñador UX/UI'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Llenar con credenciales de Michael Williams por defecto
    _updateCredentials(0);
  }

  void _updateCredentials(int index) {
    setState(() {
      _selectedUserIndex = index;
      userController.text = _availableUsers[index]['username']!;
      passController.text = _availableUsers[index]['password']!;
    });
  }

  // Login con credenciales tradicionales
  Future<void> loginWithCredentials() async {
    if (userController.text.isEmpty || passController.text.isEmpty) {
      setState(() {
        error = 'Por favor ingresa usuario y contraseña';
        success = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      error = '';
      success = '';
    });

    try {
      if (kDebugMode) {
        print('Iniciando login tradicional...');
      }
      
      // Probar la API primero
      await TraditionalAuthService.testAPI();
      
      final userData = await TraditionalAuthService.loginWithCredentials(
        userController.text.trim(),
        passController.text.trim(),
      );

      if (userData != null) {
        setState(() {
          success = 'Login exitoso! Redirigiendo...';
        });
        
        if (kDebugMode) {
          print('Login exitoso, navegando a HomeScreen');
        }
        
        // Pequeña pausa para mostrar el mensaje de éxito
        await Future.delayed(Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                userData: userData,
                isTraditionalAuth: true,
              ),
            ),
          );
        }
      } else {
        setState(() {
          error = 'Credenciales inválidas. Verifica usuario y contraseña.';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en loginWithCredentials: $e');
      }
      setState(() {
        error = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Login con Google/Firebase
  Future<void> loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      error = '';
      success = '';
    });

    try {
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              user: user,
              isTraditionalAuth: false,
            ),
          ),
        );
      } else {
        setState(() {
          error = 'Error al iniciar sesión con Google';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión con Google';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.secondaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: NeoCard(
                glowEffect: true,
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo futurista
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGreen,
                            AppTheme.accentGreenDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGreen.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 50,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Título
                    Text(
                      'NEO STORE',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tienda del Futuro',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Selector de tipo de login
                    Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            text: 'Google',
                            isSecondary: _showTraditionalLogin,
                            onPressed: () {
                              setState(() {
                                _showTraditionalLogin = false;
                                error = '';
                                success = '';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: NeoButton(
                            text: 'Usuario',
                            isSecondary: !_showTraditionalLogin,
                            onPressed: () {
                              setState(() {
                                _showTraditionalLogin = true;
                                error = '';
                                success = '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Formulario según el tipo seleccionado
                    if (_showTraditionalLogin) ...[
                      // Selector de usuario
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar Usuario:',
                              style: TextStyle(
                                color: AppTheme.accentGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 12),
                            ...List.generate(_availableUsers.length, (index) {
                              final user = _availableUsers[index];
                              return GestureDetector(
                                onTap: () => _updateCredentials(index),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _selectedUserIndex == index 
                                        ? AppTheme.accentGreen.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedUserIndex == index 
                                          ? AppTheme.accentGreen
                                          : AppTheme.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selectedUserIndex == index 
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: _selectedUserIndex == index 
                                            ? AppTheme.accentGreen
                                            : AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name']!,
                                              style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              user['description']!,
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Login tradicional
                      NeoTextField(
                        controller: userController,
                        labelText: 'Usuario',
                        hintText: _availableUsers[_selectedUserIndex]['username'],
                        prefixIcon: Icons.person_outline,
                      ),
                      SizedBox(height: 20),
                      
                      // Campo de contraseña con botón para mostrar/ocultar
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: passController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            hintText: _availableUsers[_selectedUserIndex]['password'],
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_outlined 
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: AppTheme.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.accentGreen, width: 2),
                            ),
                            labelStyle: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                            hintStyle: TextStyle(
                              color: AppTheme.textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: NeoButton(
                          text: 'INICIAR SESIÓN',
                          onPressed: _isLoading ? null : loginWithCredentials,
                          isLoading: _isLoading,
                          icon: Icons.login,
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Info del usuario seleccionado
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: AppTheme.accentGreen,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Usuario Real de DummyJSON',
                                  style: TextStyle(
                                    color: AppTheme.accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Column(
                              children: [
                                Text(
                                  _availableUsers[_selectedUserIndex]['name']!,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  _availableUsers[_selectedUserIndex]['description']!,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Login con Google
                      SizedBox(
                        width: double.infinity,
                        child: NeoButton(
                          text: 'CONTINUAR CON GOOGLE',
                          onPressed: _isLoading ? null : loginWithGoogle,
                          isLoading: _isLoading,
                          icon: Icons.login,
                          isSecondary: true,
                        ),
                      ),
                    ],

                    // Mostrar mensajes de éxito
                    if (success.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.successColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.successColor,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                success,
                                style: TextStyle(color: AppTheme.successColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Mostrar errores
                    if (error.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(color: AppTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }
}
