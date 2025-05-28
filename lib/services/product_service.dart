import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  // Obtener todos los productos
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));
    
    if (response.statusCode == 200) {
      final List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  // Obtener detalle de un producto por ID
  static Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/$id'));
    
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar producto: ${response.statusCode}');
    }
  }

  // Añadir productos al carrito (simulación)
  static Future<Map<String, dynamic>> addToCart(List<Map<String, dynamic>> products) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/carts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': 1,
        'date': DateTime.now().toIso8601String(),
        'products': products,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al agregar al carrito: ${response.statusCode}');
    }
  }

  // Obtener carrito simulado
  static Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(Uri.parse('$_baseUrl/carts/1'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener carrito: ${response.statusCode}');
    }
  }
}