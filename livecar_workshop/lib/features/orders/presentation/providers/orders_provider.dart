import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/order_model.dart';
import '../../../home/presentation/providers/home_providers.dart';

enum OrderFilter { all, pending, inProgress, completed, cancelled }

extension OrderFilterExtension on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.all: return 'الكل';
      case OrderFilter.pending: return 'بانتظار';
      case OrderFilter.inProgress: return 'جاري';
      case OrderFilter.completed: return 'مكتمل';
      case OrderFilter.cancelled: return 'ملغي';
    }
  }

  String? get statusValue {
    switch (this) {
      case OrderFilter.all: return null;
      case OrderFilter.pending: return 'pending';
      case OrderFilter.inProgress: return 'in_progress';
      case OrderFilter.completed: return 'completed';
      case OrderFilter.cancelled: return 'cancelled';
    }
  }
}

final orderFilterProvider = StateProvider<OrderFilter>((ref) => OrderFilter.all);
final orderSearchProvider = StateProvider<String>((ref) => '');

final allOrdersProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  final workshopId = ref.watch(workshopIdProvider);
  if (workshopId == null) return const Stream.empty();
  final filter = ref.watch(orderFilterProvider);
  final search = ref.watch(orderSearchProvider);

  var query = Supabase.instance.client
    .from('orders')
    .stream(primaryKey: ['id'])
    .eq('workshop_id', workshopId)
    .order('created_at', ascending: false);

  return query.map((rows) {
    var orders = rows.map((r) => OrderModel.fromJson(r)).toList();
    if (filter.statusValue != null) {
      orders = orders.where((o) => o.status == filter.statusValue).toList();
    }
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      orders = orders.where((o) =>
        (o.customerName?.toLowerCase().contains(q) ?? false) ||
        (o.vehicleInfo?.toLowerCase().contains(q) ?? false) ||
        (o.problemDescription?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return orders;
  });
});

final orderDetailProvider = FutureProvider.autoDispose.family<OrderModel?, String>((ref, orderId) async {
  // Use profiles join (customer_id FK -> profiles.id)
  final result = await Supabase.instance.client
    .from('orders')
    .select('*, profiles(full_name, phone)')
    .eq('id', orderId)
    .maybeSingle();
  if (result == null) return null;
  return OrderModel.fromJson(result);
});

class OrdersNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus(String orderId, String status, {double? totalPrice}) async {
    final data = <String, dynamic>{'status': status};
    if (totalPrice != null) data['total_price'] = totalPrice;
    if (status == 'completed') data['completed_at'] = DateTime.now().toIso8601String();
    await Supabase.instance.client.from('orders').update(data).eq('id', orderId);
  }

  Future<String> createOrder(Map<String, dynamic> orderData) async {
    final result = await Supabase.instance.client
      .from('orders')
      .insert(orderData)
      .select('id')
      .single();
    return result['id'] as String;
  }
}

final ordersNotifierProvider = AsyncNotifierProvider<OrdersNotifier, void>(OrdersNotifier.new);import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/order_model.dart';
import '../../../home/presentation/providers/home_providers.dart';

enum OrderFilter { all, pending, inProgress, completed, cancelled }

extension OrderFilterExtension on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.all: return 'الكل';
      case OrderFilter.pending: return 'بانتظار';
      case OrderFilter.inProgress: return 'جاري';
      case OrderFilter.completed: return 'مكتمل';
      case OrderFilter.cancelled: return 'ملغي';
    }
  }

  String? get statusValue {
    switch (this) {
      case OrderFilter.all: return null;
      case OrderFilter.pending: return 'pending';
      case OrderFilter.inProgress: return 'in_progress';
      case OrderFilter.completed: return 'completed';
      case OrderFilter.cancelled: return 'cancelled';
    }
  }
}

final orderFilterProvider = StateProvider<OrderFilter>((ref) => OrderFilter.all);
final orderSearchProvider = StateProvider<String>((ref) => '');

final allOrdersProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  final workshopId = ref.watch(workshopIdProvider);
  if (workshopId == null) return const Stream.empty();
  final filter = ref.watch(orderFilterProvider);
  final search = ref.watch(orderSearchProvider);

  var query = Supabase.instance.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('workshop_id', workshopId)
      .order('created_at', ascending: false);

  return query.map((rows) {
    var orders = rows.map((r) => OrderModel.fromJson(r)).toList();
    if (filter.statusValue != null) {
      orders = orders.where((o) => o.status == filter.statusValue).toList();
    }
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      orders = orders.where((o) =>
        (o.customerName?.toLowerCase().contains(q) ?? false) ||
        (o.vehicleInfo?.toLowerCase().contains(q) ?? false) ||
        (o.problemDescription?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return orders;
  });
});

final orderDetailProvider = FutureProvider.autoDispose.family<OrderModel?, String>((ref, orderId) async {
  final result = await Supabase.instance.client
      .from('orders')
      .select('*, profiles(full_name, phone)')
      .eq('id', orderId)
      .maybeSingle();
  if (result == null) return null;
  return OrderModel.fromJson(result);
});

class OrdersNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus(String orderId, String status, {double? totalPrice}) async {
    final data = <String, dynamic>{'status': status};
    if (totalPrice != null) data['total_price'] = totalPrice;
    if (status == 'completed') data['completed_at'] = DateTime.now().toIso8601String();
    await Supabase.instance.client.from('orders').update(data).eq('id', orderId);
  }

  Future<String> createOrder(Map<String, dynamic> orderData) async {
    final result = await Supabase.instance.client
        .from('orders')
        .insert(orderData)
        .select('id')
        .single();
    return result['id'] as String;
  }
}

final ordersNotifierProvider = AsyncNotifierProvider<OrdersNotifier, void>(OrdersNotifier.new);
