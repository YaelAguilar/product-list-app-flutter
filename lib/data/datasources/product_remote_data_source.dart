import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductDetails(int id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<String>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String category);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  Future<List<ProductModel>> _getProductsFromUrl(String url) async {
    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];
      return productsJson.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw ServerException('Error al cargar productos desde $url: ${response.statusCode}');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    return _getProductsFromUrl('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.productsEndpoint}');
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.productsEndpoint}/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductModel.fromJson(data as Map<String, dynamic>);
    } else {
      throw ServerException('Error al cargar detalle del producto $id: ${response.statusCode}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    return _getProductsFromUrl('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.productsSearchEndpoint}?q=$query');
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.productCategoriesEndpoint}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> categoriesJson = jsonDecode(response.body) as List<dynamic>? ?? [];
      return categoriesJson.map((category) => category.toString()).toList();
    } else {
      throw ServerException('Error al cargar categorías: ${response.statusCode}');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    return _getProductsFromUrl('${ApiConstants.dummyJsonBaseUrl}${ApiConstants.productsByCategoryEndpoint}/$category');
  }
}