import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../routing/app_routes.dart';
import '../../data/models/order_models.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return AppShell(
      title: 'My Orders',
      child: RefreshIndicator(
        onRefresh: () => ref.read(ordersProvider.notifier).refreshOrders(),
        child: ordersState.when(
          data: (orders) {
            if (orders.isEmpty) {
              return EmptyState(
                icon: Iconsax.box,
                title: 'No orders yet',
                description: 'When you place orders, they will appear here',
                actionLabel: 'Start Shopping',
                onAction: () => context.go(AppRoutes.homePath),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _OrderCard(order: orders[index]);
              },
            );
          },
          loading: () => const LoadingState(message: 'Loading orders...'),
          error: (error, stackTrace) => ErrorState(
            title: 'Failed to load orders',
            description: error.toString(),
            onRetry: () => ref.read(ordersProvider.notifier).refreshOrders(),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order});

  final OrderResponse order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusInfo = _getStatusInfo(order.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.elevatedShadow : AppColors.cardShadow,
        ),
        child: InkWell(
          onTap: () => context.go(AppRoutes.orderDetailsWithId('${order.orderId}')),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusInfo.icon,
                        color: statusInfo.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderId}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.createdAt.formattedWithTime,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PremiumBadge(
                      label: statusInfo.label,
                      variant: statusInfo.variant,
                      icon: statusInfo.icon,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Order items preview
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Item icons
                      Row(
                        children: List.generate(
                          order.items.length.clamp(0, 3),
                          (i) => Container(
                            width: 36,
                            height: 36,
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Iconsax.box,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      if (order.items.length > 3) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${order.items.length - 3}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              order.items.take(2).map((e) => e.productName).join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Footer row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.totalPrice.toRupees,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.status == 'PENDING' || order.status == 'CREATED')
                      PremiumButton(
                        label: 'Pay Now',
                        icon: Iconsax.card,
                        size: PremiumButtonSize.small,
                        onPressed: () => context.go(
                          AppRoutes.paymentWithOrderId('${order.orderId}'),
                        ),
                      )
                    else
                      PremiumButton(
                        label: 'View Details',
                        variant: PremiumButtonVariant.outline,
                        size: PremiumButtonSize.small,
                        icon: Iconsax.arrow_right_3,
                        onPressed: () => context.go(
                          AppRoutes.orderDetailsWithId('${order.orderId}'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'CREATED':
        return _StatusInfo(
          label: 'Pending Payment',
          icon: Iconsax.clock,
          color: AppColors.warning,
          variant: BadgeVariant.warning,
        );
      case 'PAID':
      case 'PROCESSING':
        return _StatusInfo(
          label: 'Processing',
          icon: Iconsax.refresh,
          color: const Color(0xFF3B82F6),
          variant: BadgeVariant.info,
        );
      case 'SHIPPED':
        return _StatusInfo(
          label: 'Shipped',
          icon: Iconsax.truck_fast,
          color: const Color(0xFF8B5CF6),
          variant: BadgeVariant.accent,
        );
      case 'DELIVERED':
        return _StatusInfo(
          label: 'Delivered',
          icon: Iconsax.tick_circle,
          color: AppColors.success,
          variant: BadgeVariant.success,
        );
      case 'CANCELLED':
        return _StatusInfo(
          label: 'Cancelled',
          icon: Iconsax.close_circle,
          color: AppColors.error,
          variant: BadgeVariant.error,
        );
      default:
        return _StatusInfo(
          label: status,
          icon: Iconsax.box,
          color: AppColors.textSecondary,
          variant: BadgeVariant.neutral,
        );
    }
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
    required this.variant,
  });

  final String label;
  final IconData icon;
  final Color color;
  final BadgeVariant variant;
}
