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
    return DashboardSummary(
      totalBookings: int.parse(json['totalBookings'].toString()),
      todayBookings: int.parse(json['todayBookings'].toString()),
      pending: int.parse(json['pending'].toString()),
      completed: int.parse(json['completed'].toString()),
      cancelled: int.parse(json['cancelled'].toString()),
      totalEarnings: json['totalEarnings'] ?? 0,
      todayEarnings: json['todayEarnings'] ?? 0,
    );
  }
}
