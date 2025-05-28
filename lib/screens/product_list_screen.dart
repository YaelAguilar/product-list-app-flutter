import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/neo_card.dart';
import '../cart/cart_notifier.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> with SingleTickerProviderStateMixin {
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fetchProducts();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final products = await ProductService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching products: $e');
      }
      setState(() {
        _error = 'Error al cargar productos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppTheme.primaryDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen,
                      AppTheme.accentGreenDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.primaryDark,
                  size: 30,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
              ),
              SizedBox(height: 16),
              Text(
                'Cargando productos...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Container(
        color: AppTheme.primaryDark,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppTheme.errorColor,
                  size: 64,
                ),
                SizedBox(height: 24),
                Text(
                  _error,
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _fetchProducts,
                  icon: Icon(Icons.refresh),
                  label: Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: AppTheme.primaryDark,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.primaryDark,
      child: RefreshIndicator(
        onRefresh: _fetchProducts,
        color: AppTheme.accentGreen,
        backgroundColor: AppTheme.cardBackground,
        child: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            
            // Crear una animación para cada producto
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index / _products.length * 0.5, // Inicio escalonado
                  0.5 + index / _products.length * 0.5, // Fin escalonado
                  curve: Curves.easeOut,
                ),
              ),
            );
            
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: _buildProductCard(product),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
  return Hero(
    tag: 'product-${product.id}',
    child: NeoCard(
      glowEffect: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen del producto
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: AppTheme.cardBackground,
              ),
              child: Stack(
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.cardBackground,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppTheme.textSecondary,
                            size: 32,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppTheme.cardBackground,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Descuento
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGreen.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-${product.discountPercentage.round()}%',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Información del producto
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Expanded(
                    child: Text(
                      product.title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Rating compacto
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppTheme.accentGreen,
                        size: 12,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '${product.rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Spacer(),
                      Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 8,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 6),
                  
                  // Precio y botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Usar el notificador para agregar al carrito
                          CartNotifier().addProduct(product);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(product.title + ' agregado al carrito'),
                              backgroundColor: AppTheme.accentGreen,
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.accentGreen.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart,
                            color: AppTheme.accentGreen,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
