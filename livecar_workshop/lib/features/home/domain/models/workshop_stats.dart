class WorkshopStats {
  final int pendingOrders;
  final int inProgressOrders;
  final int completedToday;
  final double weeklyGrowth;
  final double totalRevenueToday;
  final double totalRevenueWeek;

  const WorkshopStats({
    this.pendingOrders = 0,
    this.inProgressOrders = 0,
    this.completedToday = 0,
    this.weeklyGrowth = 0.0,
    this.totalRevenueToday = 0.0,
    this.totalRevenueWeek = 0.0,
  });

  factory WorkshopStats.fromMap(Map<String, dynamic> map) {
    return WorkshopStats(
      pendingOrders: (map['pending_orders'] as num?)?.toInt() ?? 0,
      inProgressOrders: (map['in_progress_orders'] as num?)?.toInt() ?? 0,
      completedToday: (map['completed_today'] as num?)?.toInt() ?? 0,
      weeklyGrowth: (map['weekly_growth'] as num?)?.toDouble() ?? 0.0,
      totalRevenueToday: (map['revenue_today'] as num?)?.toDouble() ?? 0.0,
      totalRevenueWeek: (map['revenue_week'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get isPositiveGrowth => weeklyGrowth >= 0;
}
