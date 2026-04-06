import 'package:equatable/equatable.dart';

class AddToCartRequest {
  const AddToCartRequest({required this.productId, required this.quantity});

  final int productId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class CartItem extends Equatable {
  const CartItem({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  final int itemId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: (json['itemId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [itemId, productId, productName, price, quantity, subtotal];
}

class CartResponse extends Equatable {
  const CartResponse({
    required this.cartId,
    required this.items,
    required this.totalPrice,
  });

  final int cartId;
  final List<CartItem> items;
  final double totalPrice;

  factory CartResponse.empty() {
    return const CartResponse(cartId: 0, items: [], totalPrice: 0);
  }

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cartId: (json['cartId'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [cartId, items, totalPrice];
}
