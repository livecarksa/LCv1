import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/orders_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/livecar_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/loading_shimmer.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _priceController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    double? price;
    if (status == 'completed') {
      final priceText = _priceController.text.trim();
      price = double.tryParse(priceText);
      if (price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u0623\u062F\u062E\u0644 \u0627\u0644\u0633\u0639\u0631 \u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A')),
        );
        return;
      }
    }
    setState(() => _isUpdating = true);
    try {
      await ref.read(ordersNotifierProvider.notifier).updateStatus(
        widget.orderId,
        status,
        totalPrice: price,
      );
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted && status == 'completed') context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u062E\u0637\u0623: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    return Scaffold(
      backgroundColor: AppColors.grayBackground,
      appBar: AppBar(
        title: const Text('\u062A\u0641\u0627\u0635\u064A\u0644 \u0627\u0644\u0637\u0644\u0628'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: orderAsync.when(
        loading: () => const LoadingShimmerList(count: 6),
        error: (e, _) => Center(child: Text('\u062E\u0637\u0623: $e')),
        data: (order) {
          if (order == null) return const Center(child: Text('\u0627\u0644\u0637\u0644\u0628 \u063A\u064A\u0631 \u0645\u0648\u062C\u0648\u062F'));
          final status = orderStatusFromString(order.status);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(right: BorderSide(color: status.color, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName ?? '\u0639\u0645\u064A\u0644',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueDark,
                              ),
                            ),
                            if (order.customerPhone != null)
                              Text(order.customerPhone!, style: const TextStyle(color: AppColors.grayDark)),
                          ],
                        ),
                      ),
                      StatusBadge(status: status),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: '\u0645\u0639\u0644\u0648\u0645\u0627\u062A \u0627\u0644\u0633\u064A\u0627\u0631\u0629',
                  children: [
                    if (order.vehicleInfo != null) _InfoRow(label: '\u0627\u0644\u0633\u064A\u0627\u0631\u0629', value: order.vehicleInfo!),
                    if (order.problemDescription != null) _InfoRow(label: '\u0627\u0644\u0645\u0634\u0643\u0644\u0629', value: order.problemDescription!),
                  ],
                ),
                const SizedBox(height: 16),
                if (order.totalPrice != null && order.totalPrice! > 0)
                  _InfoCard(
                    title: '\u0627\u0644\u0633\u0639\u0631',
                    children: [
                      _InfoRow(label: '\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A', value: '${order.totalPrice!.toStringAsFixed(0)} \u0631.\u0633'),
                    ],
                  ),
                const SizedBox(height: 24),
                if (status == OrderStatus.pending) ...[
                  LiveCarButton(
                    label: '\u0642\u0628\u0648\u0644 \u0627\u0644\u0637\u0644\u0628',
                    onPressed: () => _updateStatus('accepted'),
                    isLoading: _isUpdating,
                  ),
                  const SizedBox(height: 12),
                  LiveCarButton(
                    label: '\u0631\u0641\u0636 \u0627\u0644\u0637\u0644\u0628',
                    onPressed: () => _updateStatus('cancelled'),
                    variant: LiveCarButtonVariant.outline,
                  ),
                ] else if (status == OrderStatus.accepted) ...[
                  LiveCarButton(
                    label: '\u0628\u062F\u0621 \u0627\u0644\u0639\u0645\u0644',
                    onPressed: () => _updateStatus('in_progress'),
                    isLoading: _isUpdating,
                  ),
                ] else if (status == OrderStatus.inProgress) ...[
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '\u0627\u0644\u0633\u0639\u0631 \u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A (\u0631.\u0633)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LiveCarButton(
                    label: '\u0625\u0646\u0647\u0627\u0621 \u0627\u0644\u0637\u0644\u0628',
                    onPressed: () => _updateStatus('completed'),
                    isLoading: _isUpdating,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grayLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blueDark)),
        const Divider(height: 16),
        ...children,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.grayDark, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
