class PendingSlotBooking {
  final String orderId;
  final int userId;
  final String slotId;
  final String totalAmount;
  final String status;
  final DateTime createdAt;
  final PendingSlot slot;

  PendingSlotBooking({
    required this.orderId,
    required this.userId,
    required this.slotId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.slot,
  });

  factory PendingSlotBooking.fromJson(Map<String, dynamic> json) {
    return PendingSlotBooking(
      orderId: json['order_id'],
      userId: json['user_id'],
      slotId: json['slot_id'],
      totalAmount: json['total_amount'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      slot: PendingSlot.fromJson(json['slot']),
    );
  }
}

class PendingSlot {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalSeats;
  final int availableSeats;

  PendingSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
    required this.availableSeats,
  });

  factory PendingSlot.fromJson(Map<String, dynamic> json) {
    return PendingSlot(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalSeats: json['total_seats'],
      availableSeats: json['available_seats'],
    );
  }
}
