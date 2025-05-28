import 'package:flutter/material.dart';
import '../models/product.dart';
import '../cart/cart.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  product.image,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.image_not_supported, size: 50)),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                product.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                product.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Precio: \$${product.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Cart.add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.title} agregado al carrito')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text('Agregar al carrito', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}