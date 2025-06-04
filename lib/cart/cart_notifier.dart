import 'package:flutter/foundation.dart';
import 'cart.dart';

class CartNotifier extends ChangeNotifier {
  static final CartNotifier _instance = CartNotifier._internal();
  factory CartNotifier() => _instance;
  CartNotifier._internal();

  void addProduct(product) {
    Cart.add(product);
    notifyListeners();
  }

  void removeProduct(product) {
    Cart.remove(product);
    notifyListeners();
  }

  void removeProductCompletely(product) {
    Cart.removeCompletely(product);
    notifyListeners();
  }

  void updateQuantity(product, int quantity) {
    Cart.updateQuantity(product, quantity);
    notifyListeners();
  }

  void clearCart() {
    Cart.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkout() async {
    try {
      final result = await Cart.checkout();
      clearCart();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  int get totalItems => Cart.totalItems;
  double get total => Cart.total;
  bool get isEmpty => Cart.isEmpty;
  List get items => Cart.items;
  int get uniqueItemsCount => Cart.uniqueItemsCount;
  
  int getQuantity(product) => Cart.getQuantity(product);
  bool contains(product) => Cart.contains(product);
  
  Map<String, dynamic> getSummary() => Cart.getSummary();
  double getTotalWithDiscount(double discountPercentage) => Cart.getTotalWithDiscount(discountPercentage);
  double getTax(double taxRate) => Cart.getTax(taxRate);
  double getFinalTotal({double discountPercentage = 0, double taxRate = 0}) => 
    Cart.getFinalTotal(discountPercentage: discountPercentage, taxRate: taxRate);
}
