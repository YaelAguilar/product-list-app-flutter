import 'package:flutter/material.dart';
import '../cart/cart.dart';
import '../theme/app_theme.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../cart/cart_notifier.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  Future<void> _checkout() async {
    setState(() {
      _isCheckingOut = true;
    });

    try {
      final result = await CartNotifier().checkout();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Compra realizada exitosamente! ID: ${result['id']}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la compra: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text('Carrito de Compras'),
        backgroundColor: AppTheme.secondaryDark,
        elevation: 0,
      ),
      body: Cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: Cart.items.length,
                    itemBuilder: (context, index) {
                      final item = Cart.items[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: NeoCard(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.thumbnail,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: AppTheme.cardBackground,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: AppTheme.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$${item.product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppTheme.accentGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        Cart.remove(item.product);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        Cart.add(item.product);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: AppTheme.accentGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryDark,
                    border: Border(
                      top: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${Cart.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.accentGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: NeoButton(
                          text: 'FINALIZAR COMPRA',
                          onPressed: _isCheckingOut ? null : _checkout,
                          isLoading: _isCheckingOut,
                          icon: Icons.payment,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
