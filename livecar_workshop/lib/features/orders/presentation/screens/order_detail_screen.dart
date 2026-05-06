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
          const SnackBar(content: Text('أدخل السعر الإجمالي')),
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
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
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
        title: const Text('تفاصيل الطلب'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: orderAsync.when(
        loading: () => const LoadingShimmerList(count: 6),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (order) {
          if (order == null) return const Center(child: Text('الطلب غير موجود'));
          final status = orderStatusFromString(order.status);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Header
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
                              order.customerName ?? 'عميل',
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

                // Vehicle Info
                _InfoCard(
                  title: 'معلومات السيارة',
                  children: [
                    if (order.vehicleInfo != null)
                      _InfoRow(label: 'السيارة', value: order.vehicleInfo!),
                    if (order.problemDescription != null)
                      _InfoRow(label: 'المشكلة', value: order.problemDescription!),
                  ],
                ),
                const SizedBox(height: 16),

                // Price if completed
                if (order.totalPrice != null && order.totalPrice! > 0)
                  _InfoCard(
                    title: 'السعر',
                    children: [
                      _InfoRow(label: 'الإجمالي', value: '${order.totalPrice!.toStringAsFixed(0)} ر.س'),
                    ],
                  ),

                const SizedBox(height: 24),

                // Action Buttons
                if (status == OrderStatus.pending) ...[
                  LiveCarButton(
                    label: 'قبول الطلب',
                    onPressed: () => _updateStatus('accepted'),
                    isLoading: _isUpdating,
                  ),
                  const SizedBox(height: 12),
                  LiveCarButton(
                    label: 'رفض الطلب',
                    onPressed: () => _updateStatus('cancelled'),
                    variant: LiveCarButtonVariant.outline,
                  ),
                ] else if (status == OrderStatus.accepted) ...[
                  LiveCarButton(
                    label: 'بدء العمل',
                    onPressed: () => _updateStatus('in_progress'),
                    isLoading: _isUpdating,
                  ),
                ] else if (status == OrderStatus.inProgress) ...[
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر الإجمالي (ر.س)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LiveCarButton(
                    label: 'إنهاء الطلب',
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
}import 'package:flutter/material.dart';
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
          const SnackBar(content: Text('أدخل السعر الإجمالي')),
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
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
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
        title: const Text('تفاصيل الطلب'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: orderAsync.when(
        loading: () => const LoadingShimmerList(count: 6),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (order) {
          if (order == null) return const Center(child: Text('الطلب غير موجود'));
          final status = OrderStatus.fromString(order.status);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Header
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
                              order.customerName ?? 'عميل',
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

                // Vehicle Info
                _InfoCard(
                  title: 'معلومات السيارة',
                  children: [
                    if (order.vehicleInfo != null)
                      _InfoRow(label: 'السيارة', value: order.vehicleInfo!),
                    if (order.problemDescription != null)
                      _InfoRow(label: 'المشكلة', value: order.problemDescription!),
                  ],
                ),
                const SizedBox(height: 16),

                // Price if completed
                if (order.totalPrice != null && order.totalPrice! > 0)
                  _InfoCard(
                    title: 'السعر',
                    children: [
                      _InfoRow(label: 'الإجمالي', value: '${order.totalPrice!.toStringAsFixed(0)} ر.س'),
                    ],
                  ),

                const SizedBox(height: 24),

                // Action Buttons
                if (status == OrderStatus.pending) ...[
                  LiveCarButton(
                    label: 'قبول الطلب',
                    onPressed: () => _updateStatus('accepted'),
                    isLoading: _isUpdating,
                  ),
                  const SizedBox(height: 12),
                  LiveCarButton(
                    label: 'رفض الطلب',
                    onPressed: () => _updateStatus('cancelled'),
                    variant: LiveCarButtonVariant.outline,
                  ),
                ] else if (status == OrderStatus.accepted) ...[
                  LiveCarButton(
                    label: 'بدء العمل',
                    onPressed: () => _updateStatus('in_progress'),
                    isLoading: _isUpdating,
                  ),
                ] else if (status == OrderStatus.inProgress) ...[
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر الإجمالي (ر.س)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LiveCarButton(
                    label: 'إنهاء الطلب',
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
