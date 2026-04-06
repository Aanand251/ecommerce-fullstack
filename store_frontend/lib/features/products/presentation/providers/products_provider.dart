import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/product_repository.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  Future<List<Product>> build() async {
    _page = 0;
    _hasMore = true;
    final firstPage = await ref.read(productRepositoryProvider).getProducts(page: 0);
    _hasMore = !firstPage.last;
    return firstPage.content;
  }

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  Future<void> refreshProducts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _page = 0;
      _hasMore = true;
      final firstPage =
          await ref.read(productRepositoryProvider).getProducts(page: 0);
      _hasMore = !firstPage.last;
      return firstPage.content;
    });
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore || state.isLoading) {
      return;
    }

    _loadingMore = true;
    final current = state.valueOrNull ?? <Product>[];

    try {
      _page = _page + 1;
      final pageResponse = await ref
          .read(productRepositoryProvider)
          .getProducts(page: _page);
      _hasMore = !pageResponse.last;
      state = AsyncData([...current, ...pageResponse.content]);
    } finally {
      _loadingMore = false;
    }
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

final productDetailsProvider =
    FutureProvider.family<Product, int>((ref, productId) async {
  return ref.read(productRepositoryProvider).getProductById(productId);
});
