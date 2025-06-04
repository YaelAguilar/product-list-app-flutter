import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final double totalAmount;
  final int totalItemsCount;

  const CartEntity({
    this.items = const [],
    this.totalAmount = 0.0,
    this.totalItemsCount = 0,
  });

  bool get isEmpty => items.isEmpty;

  CartEntity copyWith({
    List<CartItemEntity>? items,
    double? totalAmount,
    int? totalItemsCount,
  }) {
    return CartEntity(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
    );
  }

  @override
  List<Object?> get props => [items, totalAmount, totalItemsCount];
}