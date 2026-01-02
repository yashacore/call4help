class VendorNotification {
  final int id;
  final int? userId;          // ✅ nullable
  final int? providerId;      // ✅ nullable
  final String orderId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorNotification({
    required this.id,
    this.userId,
    this.providerId,
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
      id: json['id'] ?? 0,
      userId: json['user_id'],          // ✅ can be null
      providerId: json['provider_id'],  // ✅ can be null
      orderId: json['order_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
