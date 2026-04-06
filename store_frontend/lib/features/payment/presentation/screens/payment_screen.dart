import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../routing/app_routes.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _creating = false;
  bool _verifying = false;

  Future<void> _startPayment(int parsedOrderId) async {
    setState(() {
      _creating = true;
    });

    try {
      final paymentOrder =
          await ref.read(paymentProvider.notifier).createOrder(parsedOrderId);
      if (!mounted) {
        return;
      }

      final paymentIdController = TextEditingController();
      final signatureController = TextEditingController();

      final shouldVerify = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Razorpay Checkout Placeholder'),
                content: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('razorpay_order_id: ${paymentOrder.razorpayOrderId}'),
                      const SizedBox(height: 8),
                      Text('amount: ${paymentOrder.amount / 100} ${paymentOrder.currency}'),
                      const SizedBox(height: 8),
                      Text('key_id: ${paymentOrder.keyId}'),
                      const SizedBox(height: 16),
                      const Text(
                        'Paste values from a successful Razorpay checkout callback to verify payment.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: paymentIdController,
                        decoration: const InputDecoration(
                          labelText: 'razorpay_payment_id',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: signatureController,
                        decoration: const InputDecoration(
                          labelText: 'razorpay_signature',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('Verify'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!mounted) {
        return;
      }

      if (!shouldVerify) {
        paymentIdController.dispose();
        signatureController.dispose();
        return;
      }

      final paymentId = paymentIdController.text.trim();
      final signature = signatureController.text.trim();
      if (paymentId.isEmpty || signature.isEmpty) {
        paymentIdController.dispose();
        signatureController.dispose();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment id and signature are required.')),
        );
        return;
      }

      setState(() {
        _verifying = true;
      });

      await ref.read(paymentProvider.notifier).verify(
            razorpayOrderId: paymentOrder.razorpayOrderId,
            paymentId: paymentId,
            signature: signature,
          );
      paymentIdController.dispose();
      signatureController.dispose();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verified successfully.')),
      );
      context.go(AppRoutes.paymentSuccessPath);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creating = false;
          _verifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedOrderId = int.tryParse(widget.orderId);

    if (parsedOrderId == null) {
      return AppShell(
        title: 'Payment',
        child: Center(child: Text('Invalid order id: ${widget.orderId}')),
      );
    }

    final statusAsync = ref.watch(paymentStatusProvider(parsedOrderId));

    return AppShell(
      title: 'Payment',
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${widget.orderId}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                statusAsync.when(
                  data: (status) => Text(
                    'Current status: ${status.status} | Amount: ${status.amountInRupees.toRupees}',
                  ),
                  loading: () => const Text('Checking payment status...'),
                  error: (error, stackTrace) =>
                      const Text('Payment record not yet created.'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _creating || _verifying
                        ? null
                        : () => _startPayment(parsedOrderId),
                    child: _creating || _verifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Razorpay Order and Verify'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a backend-connected web placeholder flow. Native Razorpay popup can be swapped in without changing repository contracts.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
