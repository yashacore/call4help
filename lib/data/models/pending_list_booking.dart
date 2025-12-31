class PendingSlotBooking {
  final String id;
  final String orderId;

  final String status;
  final String paymentStatus;
  final String totalAmount;
  final String orderType;
  final String createdAt;
  final Slot slot;

  PendingSlotBooking({
    required this.id,
    required this.orderId,

    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.orderType,
    required this.createdAt,
    required this.slot,
  });

  factory PendingSlotBooking.fromJson(Map<String, dynamic> json) {
    return PendingSlotBooking(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id'],

      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      orderType: json['order_type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      slot: Slot.fromJson(json['slot'] ?? {}),

    );
  }
}
class Slot {
  final String id;
  final String startTime;
  final String endTime;
  final int totalSeats;
  final int availableSeats;

  Slot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
    required this.availableSeats,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
    );
  }
}
