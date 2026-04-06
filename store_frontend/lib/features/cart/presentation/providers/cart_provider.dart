import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/cart_models.dart';
import '../../data/repositories/cart_repository.dart';

class CartNotifier extends AsyncNotifier<CartResponse> {
  @override
  Future<CartResponse> build() async {
    try {
      return await ref.read(cartRepositoryProvider).getCart();
    } catch (_) {
      return CartResponse.empty();
    }
  }

  Future<void> refreshCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).getCart(),
    );
  }

  Future<void> addItem({required int productId, int quantity = 1}) async {
    final previous = state.valueOrNull ?? CartResponse.empty();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).addToCart(
            AddToCartRequest(productId: productId, quantity: quantity),
          ),
    );

    if (state.hasError) {
      state = AsyncData(previous);
    }
  }

  Future<void> removeItem(int itemId) async {
    final previous = state.valueOrNull ?? CartResponse.empty();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).removeFromCart(itemId),
    );

    if (state.hasError) {
      state = AsyncData(previous);
    }
  }

  Future<void> clear() async {
    await ref.read(cartRepositoryProvider).clearCart();
    state = const AsyncData(CartResponse(cartId: 0, items: [], totalPrice: 0));
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartResponse>(
  CartNotifier.new,
);
