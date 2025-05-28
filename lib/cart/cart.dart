import '../models/product.dart';
import '../services/product_service.dart';

class Cart {
  static final List<Product> _items = [];
  static final Map<int, int> _quantities = {}; // ID del producto -> cantidad

  static void add(Product product) {
    _items.add(product);
    _quantities[product.id] = (_quantities[product.id] ?? 0) + 1;
  }

  static void remove(Product product) {
    _items.remove(product);
    if (_quantities[product.id] != null && _quantities[product.id]! > 0) {
      _quantities[product.id] = _quantities[product.id]! - 1;
      if (_quantities[product.id] == 0) {
        _quantities.remove(product.id);
      }
    }
  }

  static List<Product> get items => _items;
  
  static double get total => _items.fold(0, (sum, item) => sum + item.price);

  static Map<int, int> get quantities => _quantities;

  // Enviar carrito a la API (simulación)
  static Future<Map<String, dynamic>> checkout() async {
    // Preparar los productos para la API
    final List<Map<String, dynamic>> productsForApi = [];
    
    // Agrupar productos por ID y contar cantidades
    for (final entry in _quantities.entries) {
      productsForApi.add({
        'productId': entry.key,
        'quantity': entry.value,
      });
    }
    
    // Enviar a la API
    return await ProductService.addToCart(productsForApi);
  }

  static void clear() {
    _items.clear();
    _quantities.clear();
  }
}

/*import '../models/product.dart';

class Cart {
  static final List<Product> _items = [];
  static void add(Product product) => _items.add(product);
  static void remove(Product product) => _items.remove(product);
  static List<Product> get items => _items;
  static double get total => _items.fold(0, (sum, item) => sum + item.price);
}*/