class DashboardSummary {
  final int totalBookings;
  final int todayBookings;
  final int pending;
  final int completed;
  final int cancelled;
  final int totalEarnings;
  final int todayEarnings;

  DashboardSummary({
    required this.totalBookings,
    required this.todayBookings,
    required this.pending,
    required this.completed,
    required this.cancelled,
    required this.totalEarnings,
    required this.todayEarnings,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value.split('.').first) ?? 0;
      return 0;
    }

    return DashboardSummary(
      totalBookings: parseInt(json['totalBookings']),
      todayBookings: parseInt(json['todayBookings']),
      pending: parseInt(json['pending']),
      completed: parseInt(json['completed']),
      cancelled: parseInt(json['cancelled']),
      totalEarnings: parseInt(json['totalEarnings']),
      todayEarnings: parseInt(json['todayEarnings']),
    );
  }
}
