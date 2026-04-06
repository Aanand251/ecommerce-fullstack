import 'package:equatable/equatable.dart';

class PlaceOrderRequest {
  const PlaceOrderRequest({required this.shippingAddress});

  final String shippingAddress;

  Map<String, dynamic> toJson() {
    return {'shippingAddress': shippingAddress};
  }
}

class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, productName, quantity, price, subtotal];
}

class OrderResponse extends Equatable {
  const OrderResponse({
    required this.orderId,
    required this.status,
    required this.totalPrice,
    required this.shippingAddress,
    required this.createdAt,
    required this.items,
  });

  final int orderId;
  final String status;
  final double totalPrice;
  final String shippingAddress;
  final DateTime createdAt;
  final List<OrderItem> items;

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: (json['orderId'] as num).toInt(),
      status: json['status'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      shippingAddress: json['shippingAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [orderId, status, totalPrice, shippingAddress, createdAt, items];
}
