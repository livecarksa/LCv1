import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/home_providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/order_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(workshopStatsProvider);
    final pendingAsync = ref.watch(pendingOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.grayBackground,
      appBar: AppBar(
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'لايف كار',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'IBMPlexArabic',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workshopStatsProvider);
          ref.invalidate(pendingOrdersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statsAsync.when(
                loading: () => const LoadingShimmerList(count: 4, height: 100),
                error: (e, _) => const SizedBox(),
                data: (stats) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      label: 'طلبات قيد الانتظار',
                      value: stats.pendingOrders.toString(),
                      icon: Icons.pending_actions,
                      color: AppColors.warning,
                    ),
                    StatCard(
                      label: 'جاري العمل',
                      value: stats.inProgressOrders.toString(),
                      icon: Icons.build_circle_outlined,
                      color: AppColors.bluePrimary,
                    ),
                    StatCard(
                      label: 'مكتملة اليوم',
                      value: stats.completedToday.toString(),
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    StatCard(
                      label: 'إيرادات اليوم',
                      value: stats.totalRevenueToday.toStringAsFixed(0),
                      icon: Icons.attach_money,
                      color: AppColors.orange,
                      isCurrency: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'الإجراءات السريعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickAction(
                    label: 'طلب جديد',
                    icon: Icons.add_circle_outline,
                    color: AppColors.bluePrimary,
                    onTap: () => context.go('/orders'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'تشخيص ذكي',
                    icon: Icons.psychology_outlined,
                    color: AppColors.orange,
                    onTap: () => context.go('/ai-diagnosis'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'الطلبات',
                    icon: Icons.list_alt_outlined,
                    color: AppColors.success,
                    onTap: () => context.go('/orders'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'الإعدادات',
                    icon: Icons.settings_outlined,
                    color: AppColors.grayDark,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الطلبات الجديدة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/orders'),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              pendingAsync.when(
                loading: () => const LoadingShimmerList(count: 3),
                error: (e, _) => const SizedBox(),
                data: (orders) => orders.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.inbox_outlined,
                        title: 'لا توجد طلبات جديدة',
                        subtitle: 'ستظهر الطلبات الجديدة هنا',
                      )
                    : Column(
                        children: orders
                            .map((order) => OrderCard(
                                  order: order,
                                  onAccept: () => _updateStatus(order['id'], 'accepted'),
                                  onReject: () => _updateStatus(order['id'], 'cancelled'),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }

  Future<void> _updateStatus(String orderId, String status) async {
    await Supabase.instance.client
        .from('orders')
        .update({'status': status}).eq('id', orderId);
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    return BottomNavigationBar(
      currentIndex: _getIndex(location),
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/orders');
            break;
          case 2:
            context.go('/ai-diagnosis');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      selectedItemColor: AppColors.bluePrimary,
      unselectedItemColor: AppColors.grayMid,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية'),
        BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'الطلبات'),
        BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'تشخيص'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي'),
      ],
    );
  }

  int _getIndex(String location) {
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/ai-diagnosis')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}
