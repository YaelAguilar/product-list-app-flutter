import '../models/product.dart';
import '../services/product_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class Cart {
  static final Map<int, CartItem> _items = {};

  // Agregar producto al carrito
  static void add(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
  }

  // Remover una unidad del producto
  static void remove(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity--;
      if (_items[product.id]!.quantity <= 0) {
        _items.remove(product.id);
      }
    }
  }

  // Remover completamente un producto del carrito
  static void removeCompletely(Product product) {
    _items.remove(product.id);
  }

  // Actualizar cantidad de un producto
  static void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _items.remove(product.id);
    } else if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity = quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
  }

  // Obtener todos los items del carrito
  static List<CartItem> get items => _items.values.toList();

  // Obtener productos únicos (sin repetir)
  static List<Product> get products => _items.values.map((item) => item.product).toList();

  // Obtener cantidad total de items
  static int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  // Obtener precio total
  static double get total => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Obtener cantidad de un producto específico
  static int getQuantity(Product product) {
    return _items[product.id]?.quantity ?? 0;
  }

  // Verificar si un producto está en el carrito
  static bool contains(Product product) {
    return _items.containsKey(product.id);
  }

  // Verificar si el carrito está vacío
  static bool get isEmpty => _items.isEmpty;

  // Obtener número de productos únicos
  static int get uniqueItemsCount => _items.length;

  // Enviar carrito a la API (checkout)
  static Future<Map<String, dynamic>> checkout() async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    // Preparar los productos para la API
    final List<Map<String, dynamic>> productsForApi = _items.values.map((item) {
      return {
        'id': item.product.id,
        'quantity': item.quantity,
      };
    }).toList();
    
    try {
      // Enviar a la API
      final result = await ProductService.addToCart(productsForApi);
      
      // NO limpiar automáticamente aquí - lo hará el CartNotifier
      // if (result['id'] != null) {
      //   clear();
      // }
      
      return result;
    } catch (e) {
      throw Exception('Error en checkout: $e');
    }
  }

  // Limpiar carrito
  static void clear() {
    _items.clear();
  }

  // Obtener resumen del carrito
  static Map<String, dynamic> getSummary() {
    return {
      'totalItems': totalItems,
      'uniqueItems': uniqueItemsCount,
      'total': total,
      'isEmpty': isEmpty,
      'items': items.map((item) => {
        'product': item.product.title,
        'quantity': item.quantity,
        'price': item.product.price,
        'total': item.totalPrice,
      }).toList(),
    };
  }

  // Aplicar descuento (simulación)
  static double getTotalWithDiscount(double discountPercentage) {
    return total * (1 - discountPercentage / 100);
  }

  // Calcular impuestos (simulación)
  static double getTax(double taxRate) {
    return total * (taxRate / 100);
  }

  // Obtener total final con descuento e impuestos
  static double getFinalTotal({double discountPercentage = 0, double taxRate = 0}) {
    final discountedTotal = getTotalWithDiscount(discountPercentage);
    final tax = discountedTotal * (taxRate / 100);
    return discountedTotal + tax;
  }
}
