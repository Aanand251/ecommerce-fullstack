import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/cart_models.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(dioProvider));
});

class CartRepository {
  CartRepository(this._dio);

  final Dio _dio;

  Future<CartResponse> getCart() async {
    final response = await _dio.get(AppConstants.cartEndpoint);
    return CartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CartResponse> addToCart(AddToCartRequest request) async {
    final response = await _dio.post(
      AppConstants.addToCartEndpoint,
      data: request.toJson(),
    );
    return CartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CartResponse> removeFromCart(int itemId) async {
    final response = await _dio.delete('${AppConstants.cartEndpoint}/remove/$itemId');
    return CartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> clearCart() async {
    await _dio.delete(AppConstants.clearCartEndpoint);
  }
}
