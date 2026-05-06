import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum OrderStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'قيد الانتظار';
      case OrderStatus.accepted: return 'مقبول';
      case OrderStatus.inProgress: return 'جاري التنفيذ';
      case OrderStatus.completed: return 'مكتمل';
      case OrderStatus.cancelled: return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending: return AppColors.warning;
      case OrderStatus.accepted: return AppColors.bluePrimary;
      case OrderStatus.inProgress: return AppColors.orange;
      case OrderStatus.completed: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  Color get softColor {
    switch (this) {
      case OrderStatus.pending: return AppColors.warning.withOpacity(0.1);
      case OrderStatus.accepted: return AppColors.blueLight;
      case OrderStatus.inProgress: return AppColors.orange.withOpacity(0.1);
      case OrderStatus.completed: return AppColors.success.withOpacity(0.1);
      case OrderStatus.cancelled: return AppColors.error.withOpacity(0.1);
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending': return OrderStatus.pending;
      case 'accepted': return OrderStatus.accepted;
      case 'in_progress': return OrderStatus.inProgress;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.softColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}
