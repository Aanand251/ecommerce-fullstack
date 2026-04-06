import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../routing/app_routes.dart';
import '../../data/models/order_models.dart';
import '../providers/orders_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsedId = int.tryParse(orderId);
    if (parsedId == null) {
      return AppShell(
        title: 'Order Details',
        showBackButton: true,
        onBack: () => context.go(AppRoutes.ordersPath),
        child: ErrorState(
          title: 'Invalid Order',
          description: 'Order ID "$orderId" is not valid',
        ),
      );
    }

    final orderState = ref.watch(orderDetailsProvider(parsedId));
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppConstants.mobileBreakpoint;

    return AppShell(
      title: 'Order Details',
      showBackButton: true,
      onBack: () => context.go(AppRoutes.ordersPath),
      child: orderState.when(
        data: (order) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                _OrderHeader(order: order),
                const SizedBox(height: 24),

                // Status Timeline
                _StatusTimeline(status: order.status),
                const SizedBox(height: 24),

                // Order Items
                const SectionHeader(title: 'Items'),
                const SizedBox(height: 16),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderItemCard(item: item),
                    )),

                const SizedBox(height: 16),

                // Order Summary
                _OrderSummary(order: order),

                const SizedBox(height: 24),

                // Shipping Info
                _ShippingInfo(address: order.shippingAddress),

                const SizedBox(height: 24),

                // Action Buttons
                if (order.status == 'PENDING' || order.status == 'CREATED')
                  PremiumButton(
                    label: 'Complete Payment',
                    icon: Iconsax.card,
                    isFullWidth: true,
                    onPressed: () => context.go(
                      AppRoutes.paymentWithOrderId('${order.orderId}'),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const LoadingState(message: 'Loading order details...'),
        error: (error, stackTrace) => ErrorState(
          title: 'Failed to load order',
          description: error.toString(),
          onRetry: () => ref.invalidate(orderDetailsProvider(parsedId)),
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final OrderResponse order;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Iconsax.receipt_15,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.createdAt.formattedWithTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _StatusBadge(status: order.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final info = _getStatusInfo(status);
    return PremiumBadge(
      label: info.label,
      variant: info.variant,
      icon: info.icon,
      size: BadgeSize.large,
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'CREATED':
        return _StatusInfo('Pending', Iconsax.clock, BadgeVariant.warning);
      case 'PAID':
      case 'PROCESSING':
        return _StatusInfo('Processing', Iconsax.refresh, BadgeVariant.info);
      case 'SHIPPED':
        return _StatusInfo('Shipped', Iconsax.truck_fast, BadgeVariant.accent);
      case 'DELIVERED':
        return _StatusInfo('Delivered', Iconsax.tick_circle, BadgeVariant.success);
      case 'CANCELLED':
        return _StatusInfo('Cancelled', Iconsax.close_circle, BadgeVariant.error);
      default:
        return _StatusInfo(status, Iconsax.box, BadgeVariant.neutral);
    }
  }
}

class _StatusInfo {
  const _StatusInfo(this.label, this.icon, this.variant);
  final String label;
  final IconData icon;
  final BadgeVariant variant;
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final stages = ['Placed', 'Processing', 'Shipped', 'Delivered'];
    final currentIndex = _getStageIndex(status);

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(stages.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connector line
                final stageIndex = index ~/ 2;
                final isCompleted = stageIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }

              final stageIndex = index ~/ 2;
              final isCompleted = stageIndex <= currentIndex;
              final isCurrent = stageIndex == currentIndex;

              return _TimelineNode(
                label: stages[stageIndex],
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              );
            }),
          ),
        ],
      ),
    );
  }

  int _getStageIndex(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'CREATED':
      case 'PAID':
        return 0;
      case 'PROCESSING':
        return 1;
      case 'SHIPPED':
        return 2;
      case 'DELIVERED':
        return 3;
      default:
        return 0;
    }
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
  });

  final String label;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 40 : 32,
          height: isCurrent ? 40 : 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.success : AppColors.border,
              width: 2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted ? Iconsax.tick_circle5 : Iconsax.record,
            size: isCurrent ? 20 : 16,
            color: isCompleted ? Colors.white : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            color: isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.shopping_bag,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${item.price.toRupees}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.subtotal.toRupees,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final OrderResponse order;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: order.totalPrice.toRupees),
          const SizedBox(height: 12),
          const _SummaryRow(label: 'Shipping', value: 'FREE', valueColor: AppColors.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider),
          ),
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
                order.totalPrice.toRupees,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
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
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ShippingInfo extends StatelessWidget {
  const _ShippingInfo({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.location,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
