import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_models.dart';
import '../../data/repositories/order_repository.dart';

class OrdersNotifier extends AsyncNotifier<List<OrderResponse>> {
  @override
  Future<List<OrderResponse>> build() async {
    return ref.read(orderRepositoryProvider).getMyOrders();
  }

  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).getMyOrders(),
    );
  }

  Future<OrderResponse> placeOrder(String shippingAddress) async {
    final order = await ref.read(orderRepositoryProvider).placeOrder(
          PlaceOrderRequest(shippingAddress: shippingAddress),
        );

    final current = state.valueOrNull ?? <OrderResponse>[];
    state = AsyncData([order, ...current]);
    return order;
  }
}

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderResponse>>(
  OrdersNotifier.new,
);

final orderDetailsProvider =
    FutureProvider.family<OrderResponse, int>((ref, orderId) {
  return ref.read(orderRepositoryProvider).getOrderById(orderId);
});
