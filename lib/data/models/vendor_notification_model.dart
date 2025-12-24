class VendorNotification {
  final int id;
  final int userId;
  final int providerId;
  final String orderId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorNotification({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.orderId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorNotification.fromJson(Map<String, dynamic> json) {
    return VendorNotification(
      id: json['id'],
      userId: json['user_id'],
      providerId: json['provider_id'],
      orderId: json['order_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
