import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

abstract class CartRemoteDataSource {
  Future<Map<String, dynamic>> sendCartToApi(List<Map<String, dynamic>> products);
  Future<Map<String, dynamic>> getUserCartFromApi(int userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;

  CartRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> sendCartToApi(List<Map<String, dynamic>> products) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.cartsAddEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': 1,
        'products': products,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException('Error al procesar el carrito en la API: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserCartFromApi(int userId) async {
     final response = await client.get(
      Uri.parse('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.userCartsEndpoint}/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException('Error al obtener carrito del usuario $userId: ${response.statusCode}');
    }
  }
}