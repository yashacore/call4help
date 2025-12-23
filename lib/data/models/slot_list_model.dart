class SlotListModel {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalSeats;
  final int availableSeats;
  final bool isLocked;

  SlotListModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
    required this.availableSeats,
    required this.isLocked,
  });

  factory SlotListModel.fromJson(Map<String, dynamic> json) {
    return SlotListModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalSeats: json['total_seats'],
      availableSeats: json['available_seats'],
      isLocked: json['is_locked'],
    );
  }
}
