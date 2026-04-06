import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/payment_models.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentNotifier extends AsyncNotifier<PaymentOrderResponse?> {
  @override
  Future<PaymentOrderResponse?> build() async {
    return null;
  }

  Future<PaymentOrderResponse> createOrder(int orderId) async {
    final response = await ref.read(paymentRepositoryProvider).createPaymentOrder(orderId);
    state = AsyncData(response);
    return response;
  }

  Future<void> verify({
    required String razorpayOrderId,
    required String paymentId,
    required String signature,
  }) async {
    await ref.read(paymentRepositoryProvider).verifyPayment(
          VerifyPaymentRequest(
            razorpayOrderId: razorpayOrderId,
            razorpayPaymentId: paymentId,
            razorpaySignature: signature,
          ),
        );
  }
}

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, PaymentOrderResponse?>(
  PaymentNotifier.new,
);

final paymentStatusProvider = FutureProvider.family<PaymentStatus, int>((ref, orderId) {
  return ref.read(paymentRepositoryProvider).getPaymentStatus(orderId);
});
