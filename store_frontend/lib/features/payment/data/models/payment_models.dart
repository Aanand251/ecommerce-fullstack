import 'package:equatable/equatable.dart';

class PaymentOrderResponse extends Equatable {
  const PaymentOrderResponse({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.orderId,
    required this.keyId,
  });

  final String razorpayOrderId;
  final int amount;
  final String currency;
  final int orderId;
  final String keyId;

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResponse(
      razorpayOrderId: json['razorpayOrderId'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      orderId: (json['orderId'] as num).toInt(),
      keyId: json['keyId'] as String,
    );
  }

  @override
  List<Object?> get props => [razorpayOrderId, amount, currency, orderId, keyId];
}

class VerifyPaymentRequest {
  const VerifyPaymentRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  Map<String, dynamic> toJson() {
    return {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    };
  }
}

class PaymentStatus extends Equatable {
  const PaymentStatus({
    required this.orderId,
    required this.status,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.amount,
    required this.amountInRupees,
    required this.createdAt,
  });

  final int orderId;
  final String status;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final int amount;
  final double amountInRupees;
  final String createdAt;

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      orderId: (json['orderId'] as num).toInt(),
      status: json['status'] as String,
      razorpayOrderId: json['razorpayOrderId'] as String? ?? '',
      razorpayPaymentId: json['razorpayPaymentId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      amountInRupees: (json['amountInRupees'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [orderId, status, razorpayOrderId, razorpayPaymentId, amount, amountInRupees, createdAt];
}
