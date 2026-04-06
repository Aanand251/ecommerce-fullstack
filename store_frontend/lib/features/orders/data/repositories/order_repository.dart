import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_models.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioProvider));
});

class OrderRepository {
  OrderRepository(this._dio);

  final Dio _dio;

  Future<OrderResponse> placeOrder(PlaceOrderRequest request) async {
    final response = await _dio.post(
      AppConstants.placeOrderEndpoint,
      data: request.toJson(),
    );

    return OrderResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<OrderResponse>> getMyOrders() async {
    final response = await _dio.get(AppConstants.myOrdersEndpoint);
    return (response.data as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(OrderResponse.fromJson)
        .toList();
  }

  Future<OrderResponse> getOrderById(int orderId) async {
    final response = await _dio.get('${AppConstants.ordersEndpoint}/$orderId');
    return OrderResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
