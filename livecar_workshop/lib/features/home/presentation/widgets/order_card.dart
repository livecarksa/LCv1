import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromString(order['status'] ?? 'pending');
    final customerName = order['users']?['full_name'] ?? 'عميل غير معروف';
    final vehicleInfo = order['vehicle_info'] ?? '';
    final createdAt = order['created_at'] != null
        ? DateTime.tryParse(order['created_at'].toString())
        : null;

    return GestureDetector(
      onTap: () => context.push('/orders/${order['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            right: BorderSide(color: status.color, width: 4),
            top: BorderSide(color: AppColors.grayLight),
            bottom: BorderSide(color: AppColors.grayLight),
            left: BorderSide(color: AppColors.grayLight),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueDark,
                      ),
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              if (vehicleInfo.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  vehicleInfo,
                  style: const TextStyle(fontSize: 13, color: AppColors.grayDark),
                ),
              ],
              if (createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.grayMid),
                ),
              ],
              if (status == OrderStatus.pending && (onAccept != null || onReject != null)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('قبول', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    if (onAccept != null && onReject != null) const SizedBox(width: 8),
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('رفض', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
