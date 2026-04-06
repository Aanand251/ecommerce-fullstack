import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../routing/app_routes.dart';
import '../../data/models/cart_models.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppConstants.mobileBreakpoint;

    return AppShell(
      title: 'Shopping Cart',
      child: cartState.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return EmptyState(
              icon: Iconsax.shopping_cart,
              title: 'Your cart is empty',
              description: 'Looks like you haven\'t added any items to your cart yet.',
              actionLabel: 'Start Shopping',
              onAction: () => context.go(AppRoutes.homePath),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 980;

              final cartList = _CartItemsList(
                items: cart.items,
                onRemove: (itemId) => ref.read(cartProvider.notifier).removeItem(itemId),
              );

              final summary = _CartSummary(
                subtotal: cart.totalPrice,
                itemCount: cart.items.length,
                onCheckout: () => context.go(AppRoutes.checkoutPath),
                onClear: () => _showClearDialog(context, ref),
              );

              if (isCompact) {
                return Column(
                  children: [
                    Expanded(child: cartList),
                    const SizedBox(height: 16),
                    summary,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: cartList),
                  const SizedBox(width: 24),
                  SizedBox(width: 380, child: summary),
                ],
              );
            },
          );
        },
        loading: () => const LoadingState(message: 'Loading your cart...'),
        error: (error, stackTrace) => ErrorState(
          title: 'Failed to load cart',
          description: error.toString(),
          onRetry: () => ref.read(cartProvider.notifier).refreshCart(),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemsList extends StatelessWidget {
  const _CartItemsList({
    required this.items,
    required this.onRemove,
  });

  final List<CartItem> items;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _CartItemCard(
          item: item,
          onRemove: () => onRemove(item.itemId),
        );
      },
    );
  }
}

class _CartItemCard extends StatefulWidget {
  const _CartItemCard({
    required this.item,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onRemove;

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  bool _hovered = false;
  bool _removing = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppConstants.mobileBreakpoint;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? AppColors.primary.withValues(alpha: 0.15) : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.elevatedShadow : AppColors.cardShadow,
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: isMobile ? 72 : 100,
              height: isMobile ? 72 : 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Iconsax.shopping_bag,
                  size: isMobile ? 28 : 36,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 20),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Unit price: ${item.price.toRupees}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove button
                      PremiumIconButton(
                        icon: _removing ? Icons.hourglass_empty : Iconsax.trash,
                        onPressed: _removing
                            ? null
                            : () {
                                setState(() => _removing = true);
                                widget.onRemove();
                              },
                        tooltip: 'Remove',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Quantity and Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.box,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Qty: ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subtotal
                      Text(
                        item.subtotal.toRupees,
                        style: TextStyle(
                          fontSize: isMobile ? 17 : 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.itemCount,
    required this.onCheckout,
    required this.onClear,
  });

  final double subtotal;
  final int itemCount;
  final VoidCallback onCheckout;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const shipping = 0.0;
    final total = subtotal + shipping;

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Iconsax.receipt_2, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Items count
          _SummaryRow(
            label: 'Items ($itemCount)',
            value: subtotal.toRupees,
          ),
          const SizedBox(height: 12),

          // Shipping
          _SummaryRow(
            label: 'Shipping',
            value: shipping > 0 ? shipping.toRupees : 'FREE',
            valueColor: shipping > 0 ? null : AppColors.success,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                total.toRupees,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Checkout button
          PremiumButton(
            label: 'Proceed to Checkout',
            onPressed: onCheckout,
            isFullWidth: true,
            icon: Iconsax.arrow_right_3,
          ),
          const SizedBox(height: 12),

          // Clear cart button
          PremiumButton(
            label: 'Clear Cart',
            onPressed: onClear,
            variant: PremiumButtonVariant.ghost,
            isFullWidth: true,
            icon: Iconsax.trash,
          ),

          const SizedBox(height: 16),

          // Secure checkout note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.shield_tick5,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Secure checkout',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
