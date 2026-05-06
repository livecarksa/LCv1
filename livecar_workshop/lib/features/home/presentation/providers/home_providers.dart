import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/workshop_stats.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final workshopIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider).value;
  return authState?.workshopId;
});

final workshopStatsProvider = StreamProvider.autoDispose<WorkshopStats>((ref) {
  final workshopId = ref.watch(workshopIdProvider);
  if (workshopId == null) return const Stream.empty();
  final supabase = Supabase.instance.client;

  return supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('workshop_id', workshopId)
      .map((rows) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final weekStart = todayStart.subtract(const Duration(days: 7));

        final pending = rows.where((r) => r['status'] == 'pending').length;
        final inProgress = rows.where((r) => r['status'] == 'in_progress').length;
        final completedToday = rows.where((r) {
          final status = r['status'];
          final updatedAt = r['updated_at'];
          if (status != 'completed' || updatedAt == null) return false;
          final date = DateTime.tryParse(updatedAt.toString());
          return date != null && date.isAfter(todayStart);
        }).length;

        final revenueToday = rows
            .where((r) {
              if (r['status'] != 'completed' || r['updated_at'] == null) return false;
              final date = DateTime.tryParse(r['updated_at'].toString());
              return date != null && date.isAfter(todayStart);
            })
            .fold(0.0, (sum, r) => sum + ((r['total_price'] as num?)?.toDouble() ?? 0));

        final revenueWeek = rows
            .where((r) {
              if (r['status'] != 'completed' || r['updated_at'] == null) return false;
              final date = DateTime.tryParse(r['updated_at'].toString());
              return date != null && date.isAfter(weekStart);
            })
            .fold(0.0, (sum, r) => sum + ((r['total_price'] as num?)?.toDouble() ?? 0));

        return WorkshopStats(
          pendingOrders: pending,
          inProgressOrders: inProgress,
          completedToday: completedToday,
          totalRevenueToday: revenueToday,
          totalRevenueWeek: revenueWeek,
        );
      });
});

final pendingOrdersProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final workshopId = ref.watch(workshopIdProvider);
  if (workshopId == null) return const Stream.empty();

  return Supabase.instance.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('workshop_id', workshopId)
      .order('created_at', ascending: false)
      .map((rows) => rows.where((r) => r['status'] == 'pending').take(5).toList());
});

final inProgressOrdersProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final workshopId = ref.watch(workshopIdProvider);
  if (workshopId == null) return const Stream.empty();

  return Supabase.instance.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('workshop_id', workshopId)
      .order('created_at', ascending: false)
      .map((rows) => rows.where((r) => r['status'] == 'in_progress').take(5).toList());
});
