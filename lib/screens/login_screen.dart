import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/traditional_auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final userController = TextEditingController();
  final passController = TextEditingController();
  
  String error = '';
  String success = '';
  bool _isLoading = false;
  bool _showTraditionalLogin = false;

  @override
  void initState() {
    super.initState();
    // Llenar con credenciales de prueba por defecto
    userController.text = 'yaels';
    passController.text = 'yaelspass';
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
      print('Iniciando login tradicional...');
      
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
        
        print('Login exitoso, navegando a HomeScreen');
        
        // Pequeña pausa para mostrar el mensaje de éxito
        await Future.delayed(Duration(milliseconds: 500));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userData: userData,
              isTraditionalAuth: true,
            ),
          ),
        );
      } else {
        setState(() {
          error = 'Credenciales inválidas o error del servidor';
        });
      }
    } catch (e) {
      print('Error en loginWithCredentials: $e');
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
      if (user != null) {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[800]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo o título
                      Icon(
                        Icons.shopping_bag,
                        size: 80,
                        color: Colors.blue[800],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Tienda de Productos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Alternar entre tipos de login
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showTraditionalLogin = false;
                                  error = '';
                                  success = '';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !_showTraditionalLogin 
                                  ? Colors.blue[800] 
                                  : Colors.grey[300],
                                foregroundColor: !_showTraditionalLogin 
                                  ? Colors.white 
                                  : Colors.black,
                              ),
                              child: Text('Google'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showTraditionalLogin = true;
                                  error = '';
                                  success = '';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _showTraditionalLogin 
                                  ? Colors.blue[800] 
                                  : Colors.grey[300],
                                foregroundColor: _showTraditionalLogin 
                                  ? Colors.white 
                                  : Colors.black,
                              ),
                              child: Text('Usuario/Contraseña'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Formulario según el tipo seleccionado
                      if (_showTraditionalLogin) ...[
                        // Login tradicional
                        TextField(
                          controller: userController,
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            hintText: 'yaels',
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'yaelspass',
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : loginWithCredentials,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Iniciar Sesión'),
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[300]!),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Credenciales de prueba:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Usuario: yaels\nContraseña: yaelspass',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Login con Google
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : loginWithGoogle,
                            icon: _isLoading 
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.login),
                            label: Text(
                              _isLoading ? 'Iniciando sesión...' : 'Iniciar sesión con Google',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[800],
                              side: BorderSide(color: Colors.blue[800]!),
                            ),
                          ),
                        ),
                      ],

                      // Mostrar mensajes de éxito
                      if (success.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  success,
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Mostrar errores
                      if (error.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[700], size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error,
                                  style: TextStyle(color: Colors.red[700]),
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
