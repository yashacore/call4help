class BookingDetail {
  final String id;
  final String status;
  final String paymentStatus;
  final String totalAmount;
  final String createdAt;

  final Cafe cafe;
  final Slot slot;

  BookingDetail({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.cafe,
    required this.slot,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      totalAmount: json['total_amount'],
      createdAt: json['created_at'],
      cafe: Cafe.fromJson(json['cafe']),
      slot: Slot.fromJson(json['slot']),
    );
  }
}

class Cafe {
  final String shopName;
  final String ownerName;
  final String phone;
  final String city;
  final String address1;
  final String address2;

  Cafe({
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.city,
    required this.address1,
    required this.address2,
  });

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      shopName: json['shop_name'],
      ownerName: json['owner_name'],
      phone: json['phone'],
      city: json['city'],
      address1: json['address_line1'],
      address2: json['address_line2'],
    );
  }
}

class Slot {
  final String date;
  final String startTime;
  final String endTime;
  final int totalSeats;
  final int availableSeats;

  Slot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
    required this.availableSeats,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalSeats: json['total_seats'],
      availableSeats: json['available_seats'],
    );
  }
}
