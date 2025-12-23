class TimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final int availableSeats;
  final bool isLocked;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.availableSeats,
    required this.isLocked,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      availableSeats: json['available_seats'],
      isLocked: json['is_locked'],
    );
  }
}
