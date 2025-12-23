class UserNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String orderId;
  final String createdAt;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.orderId,
    required this.createdAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      orderId: json['order_id'],
      createdAt: json['created_at'],
    );
  }

  UserNotification copyWith({
    bool? isRead,
  }) {
    return UserNotification(
      id: id,
      title: title,
      message: message,
      orderId: orderId,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

}
