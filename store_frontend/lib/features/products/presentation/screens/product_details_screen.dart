import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../routing/app_routes.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  bool _adding = false;

  Future<void> _addToCart(int productId) async {
    setState(() => _adding = true);

    try {
      await ref
          .read(cartProvider.notifier)
          .addItem(productId: productId, quantity: _quantity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Iconsax.tick_circle5, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Added to cart successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => context.go(AppRoutes.cartPath),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.productId);
    if (id == null) {
      return AppShell(
        title: 'Product Details',
        showBackButton: true,
        onBack: () => context.go(AppRoutes.homePath),
        child: ErrorState(
          title: 'Invalid Product',
          description: 'Product ID "${widget.productId}" is not valid',
        ),
      );
    }

    final productState = ref.watch(productDetailsProvider(id));
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppConstants.mobileBreakpoint;

    return AppShell(
      title: 'Product Details',
      showBackButton: true,
      onBack: () => context.go(AppRoutes.homePath),
      child: productState.when(
        data: (product) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 900;
              final isOutOfStock = product.stock <= 0;

              final imageSection = _ProductImageSection(
                imageUrl: product.imageUrl,
                isCompact: isCompact,
              );

              final detailsSection = SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    if (product.categoryName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumBadge(
                          label: product.categoryName!,
                          variant: BadgeVariant.accent,
                        ),
                      ),

                    // Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Text(
                      product.price.toRupees,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stock Status
                    Row(
                      children: [
                        StatusDot(
                          variant: isOutOfStock
                              ? BadgeVariant.error
                              : product.stock < 5
                                  ? BadgeVariant.warning
                                  : BadgeVariant.success,
                          pulsing: !isOutOfStock && product.stock < 5,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isOutOfStock
                              ? 'Out of Stock'
                              : product.stock < 5
                                  ? 'Only ${product.stock} left'
                                  : '${product.stock} in stock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? AppColors.error
                                : product.stock < 5
                                    ? AppColors.warning
                                    : AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    const PremiumDivider(),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.description?.isNotEmpty == true
                          ? product.description!
                          : 'No description provided for this product.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    const PremiumDivider(),

                    // Quantity Selector
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    QuantitySelector(
                      quantity: _quantity,
                      max: product.stock,
                      onChanged: (value) => setState(() => _quantity = value),
                    ),

                    const SizedBox(height: 28),

                    // Add to Cart Button
                    PremiumButton(
                      label: isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                      icon: Iconsax.shopping_cart5,
                      onPressed: isOutOfStock || _adding
                          ? null
                          : () => _addToCart(product.id),
                      isLoading: _adding,
                      isFullWidth: true,
                      size: PremiumButtonSize.large,
                    ),

                    const SizedBox(height: 12),

                    // Buy Now Button
                    if (!isOutOfStock)
                      PremiumButton(
                        label: 'Buy Now',
                        icon: Iconsax.flash_15,
                        variant: PremiumButtonVariant.secondary,
                        onPressed: () async {
                          await _addToCart(product.id);
                          if (mounted) {
                            context.go(AppRoutes.checkoutPath);
                          }
                        },
                        isFullWidth: true,
                        size: PremiumButtonSize.large,
                      ),

                    const SizedBox(height: 28),

                    // Features Row
                    _FeaturesRow(),
                  ],
                ),
              );

              if (isCompact) {
                return ListView(
                  children: [
                    imageSection,
                    const SizedBox(height: 24),
                    detailsSection,
                    const SizedBox(height: 32),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: imageSection),
                  const SizedBox(width: 40),
                  Expanded(flex: 6, child: detailsSection),
                ],
              );
            },
          );
        },
        loading: () => const LoadingState(message: 'Loading product...'),
        error: (error, stackTrace) => ErrorState(
          title: 'Failed to load product',
          description: error.toString(),
          onRetry: () => ref.invalidate(productDetailsProvider(id)),
        ),
      ),
    );
  }
}

class _ProductImageSection extends StatelessWidget {
  const _ProductImageSection({
    required this.imageUrl,
    required this.isCompact,
  });

  final String? imageUrl;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: isCompact ? 1.2 : 1,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackImage(),
                )
              : _fallbackImage(),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Icon(
        Iconsax.image,
        size: 72,
        color: AppColors.textTertiary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _FeaturesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FeatureItem(
            icon: Iconsax.truck_fast,
            label: 'Free Delivery',
          ),
          _FeatureItem(
            icon: Iconsax.shield_tick,
            label: 'Secure Payment',
          ),
          _FeatureItem(
            icon: Iconsax.refresh_left_square,
            label: 'Easy Returns',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
