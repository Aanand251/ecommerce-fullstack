import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_models.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(dioProvider));
});

class PaymentRepository {
  PaymentRepository(this._dio);

  final Dio _dio;

  Future<PaymentOrderResponse> createPaymentOrder(int orderId) async {
    final response = await _dio.post('${AppConstants.createPaymentEndpoint}/$orderId');
    return PaymentOrderResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> verifyPayment(VerifyPaymentRequest request) async {
    await _dio.post(
      AppConstants.verifyPaymentEndpoint,
      data: request.toJson(),
    );
  }

  Future<PaymentStatus> getPaymentStatus(int orderId) async {
    final response = await _dio.get('${AppConstants.paymentsEndpoint}/status/$orderId');
    return PaymentStatus.fromJson(response.data as Map<String, dynamic>);
  }
}
