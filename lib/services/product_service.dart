import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Error al cargar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> categories = jsonDecode(response.body);
        return categories.map((category) => category.toString()).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos por categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> addToCart(List<Map<String, dynamic>> products) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/carts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1, // Usuario de prueba
          'products': products,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al procesar carrito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al procesar carrito: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserCart(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/carts/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener carrito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener carrito: $e');
    }
  }
}
