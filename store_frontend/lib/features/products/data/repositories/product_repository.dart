import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/models.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  ProductRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<Product>> getProducts({
    int page = 0,
    int size = 12,
    String sortBy = 'id',
  }) async {
    final response = await _dio.get(
      AppConstants.productsEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': sortBy,
      },
    );

    return PageResponse<Product>.fromJson(
      response.data as Map<String, dynamic>,
      Product.fromJson,
    );
  }

  Future<Product> getProductById(int id) async {
    final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Product>> search(String keyword) async {
    try {
      final response = await _dio.get(
        '${AppConstants.productsEndpoint}/search',
        queryParameters: {'keyword': keyword},
      );

      final data = (response.data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();

      return data;
    } catch (error, stackTrace) {
      AppLogger.error('Product search failed', error, stackTrace);
      rethrow;
    }
  }
}
