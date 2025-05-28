import 'package:flutter/material.dart';
import '../cart/cart.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  // Agrupar productos por ID para mostrar cantidad
  Map<int, CartItem> _groupCartItems() {
    final Map<int, CartItem> groupedItems = {};
    
    for (Product product in Cart.items) {
      if (groupedItems.containsKey(product.id)) {
        groupedItems[product.id]!.quantity++;
      } else {
        groupedItems[product.id] = CartItem(product: product, quantity: 1);
      }
    }
    
    return groupedItems;
  }

  Future<void> _checkout() async {
    if (Cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      final response = await Cart.checkout();
      
      // Limpiar carrito después de la compra exitosa
      Cart.clear();
      
      setState(() {});
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compra realizada con éxito. ID de orden: ${response['id']}'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la compra: $e')),
      );
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupCartItems();
    final items = groupedItems.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Carrito de Compras')),
      body: items.isEmpty
        ? Center(child: Text('El carrito está vacío', style: TextStyle(fontSize: 18)))
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item.product;
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Imagen del producto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.network(
                          product.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      
                      // Información del producto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text('\$${product.price.toStringAsFixed(2)}'),
                            SizedBox(height: 4),
                            Text('Cantidad: ${item.quantity}'),
                          ],
                        ),
                      ),
                      
                      // Botones de acción
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                Cart.add(product);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                Cart.remove(product);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '\$${Cart.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCheckingOut ? null : _checkout,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isCheckingOut
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Finalizar Compra', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase auxiliar para agrupar productos
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}