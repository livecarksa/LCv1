import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orders_provider.dart';
import '../../../home/presentation/widgets/order_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(orderSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.grayBackground,
      appBar: AppBar(
        title: const Text('الطلبات'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.bluePrimary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو السيارة...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.grayMid),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(orderSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: OrderFilter.values.map((filter) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(filter.label),
                  selected: selectedFilter == filter,
                  onSelected: (_) => ref.read(orderFilterProvider.notifier).state = filter,
                  selectedColor: AppColors.bluePrimary,
                  labelStyle: TextStyle(
                    color: selectedFilter == filter ? Colors.white : AppColors.grayDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              loading: () => const LoadingShimmerList(count: 5),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (orders) => orders.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.inbox_outlined,
                      title: 'لا توجد طلبات',
                      subtitle: 'لم يتم العثور على طلبات مطابقة',
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(allOrdersProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (_, i) => OrderCard(
                          order: {
                            ...orders[i].toJson(),
                            'id': orders[i].id,
                            'users': {'full_name': orders[i].customerName},
                          },
                          onAccept: orders[i].status == 'pending'
                              ? () => ref.read(ordersNotifierProvider.notifier).updateStatus(orders[i].id, 'accepted')
                              : null,
                          onReject: orders[i].status == 'pending'
                              ? () => ref.read(ordersNotifierProvider.notifier).updateStatus(orders[i].id, 'cancelled')
                              : null,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orders_provider.dart';
import '../../home/presentation/widgets/order_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(orderSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.grayBackground,
      appBar: AppBar(
        title: const Text('الطلبات'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.bluePrimary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو السيارة...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.grayMid),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(orderSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: OrderFilter.values.map((filter) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(filter.label),
                  selected: selectedFilter == filter,
                  onSelected: (_) => ref.read(orderFilterProvider.notifier).state = filter,
                  selectedColor: AppColors.bluePrimary,
                  labelStyle: TextStyle(
                    color: selectedFilter == filter ? Colors.white : AppColors.grayDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              loading: () => const LoadingShimmerList(count: 5),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (orders) => orders.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.inbox_outlined,
                      title: 'لا توجد طلبات',
                      subtitle: 'لم يتم العثور على طلبات مطابقة',
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(allOrdersProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (_, i) => OrderCard(
                          order: orders[i].toJson()
                            ..['id'] = orders[i].id
                            ..['users'] = {'full_name': orders[i].customerName},
                          onAccept: orders[i].status == 'pending'
                              ? () => ref.read(ordersNotifierProvider.notifier).updateStatus(orders[i].id, 'accepted')
                              : null,
                          onReject: orders[i].status == 'pending'
                              ? () => ref.read(ordersNotifierProvider.notifier).updateStatus(orders[i].id, 'cancelled')
                              : null,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
