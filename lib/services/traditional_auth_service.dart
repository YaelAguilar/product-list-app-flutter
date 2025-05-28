import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TraditionalAuthService {
  static const String _baseUrl = 'https://dummyjson.com/auth';

  static Future<Map<String, dynamic>?> loginWithCredentials(
    String username, 
    String password
  ) async {
    try {
      print('Intentando login con usuario: $username');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Datos recibidos: $data');
        
        String? token = data['accessToken'] ?? data['token'];
        
        if (token != null) {
          print('Token encontrado: ${token.substring(0, 20)}...');
          
          data['token'] = token;
          
          await _saveToken(token);
          await _saveUserData(data);
          
          return data;
        } else {
          print('Token no encontrado en la respuesta');
          print('Campos disponibles: ${data.keys.toList()}');
          return null;
        }
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        print('Cuerpo del error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login tradicional: $e');
      return null;
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('Token guardado exitosamente');
    } catch (e) {
      print('Error guardando token: $e');
    }
  }

  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
      print('Datos de usuario guardados exitosamente');
    } catch (e) {
      print('Error guardando datos de usuario: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      print('Error obteniendo datos de usuario: $e');
      return null;
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print('Sesión cerrada exitosamente');
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }

  static Future<bool> hasActiveSession() async {
    try {
      final token = await getToken();
      final hasSession = token != null && token.isNotEmpty;
      print('Verificando sesión activa: $hasSession');
      return hasSession;
    } catch (e) {
      print('Error verificando sesión activa: $e');
      return false;
    }
  }

  static Future<void> testAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/users'),
      );
      print('Test API - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Test API - Conexión exitosa');
      }
    } catch (e) {
      print('Error en test API: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('https://dummyjson.com/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario actual: $e');
      return null;
    }
  }

  static List<Map<String, String>> getValidCredentials() {
    return [
      {
        'username': 'michaelw', 
        'password': 'michaelwpass', 
        'name': 'Michael Williams',
        'description': 'Desarrollador de Software',
        'role': 'Senior Developer',
        'status': 'Verificado ✓'
      },
      {
        'username': 'jamesd', 
        'password': 'jamesdpass', 
        'name': 'James Davis',
        'description': 'Diseñador UX/UI',
        'role': 'Lead Designer',
        'status': 'Verificado ✓'
      },
    ];
  }
}
