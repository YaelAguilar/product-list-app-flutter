import 'package:flutter/material.dart';
import '../cart/cart.dart';
import '../cart/cart_notifier.dart';
import '../theme/app_theme.dart';

class CartIcon extends StatefulWidget {
  final VoidCallback? onTap;

  const CartIcon({super.key, this.onTap});

  @override
  CartIconState createState() => CartIconState();
}

class CartIconState extends State<CartIcon> {
  final CartNotifier _cartNotifier = CartNotifier();

  @override
  void initState() {
    super.initState();
    _cartNotifier.addListener(_updateCart);
  }

  @override
  void dispose() {
    _cartNotifier.removeListener(_updateCart);
    super.dispose();
  }

  void _updateCart() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(right: 8),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.accentGreen,
                size: 24,
              ),
            ),
            if (Cart.totalItems > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGreen.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '${Cart.totalItems > 99 ? '99+' : Cart.totalItems}',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
