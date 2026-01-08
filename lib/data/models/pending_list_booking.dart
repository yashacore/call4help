class PendingSlotBooking {
  final String id;        // booking id (same as order id)
  final String orderId;   // alias for id (used in UI / logic)

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
    final String bookingId = json['id']?.toString() ?? '';

    return PendingSlotBooking(
      id: bookingId,
      orderId: json['order_id']?.toString() ?? '0',

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
      totalSeats: int.tryParse(json['total_seats']?.toString() ?? '0') ?? 0,
      availableSeats:
      int.tryParse(json['available_seats']?.toString() ?? '0') ?? 0,
    );
  }
}
