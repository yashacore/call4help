// models/earnings_response.dart

class EarningsResponse {
  final bool success;
  final int? providerId;
  final String? filter;
  final int? totalServices;
  final String? totalEarnings;
  final int? totalWaitingCharges;
  final List<ServiceEarning>? services;

  EarningsResponse({
    required this.success,
    this.providerId,
    this.filter,
    this.totalServices,
    this.totalEarnings,
    this.totalWaitingCharges,
    this.services,
  });

  factory EarningsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsResponse(
      success: json['success'] ?? false,
      providerId: json['provider_id'] is String
          ? int.tryParse(json['provider_id'])
          : json['provider_id'] as int?,
      filter: json['filter']?.toString(),
      totalServices: json['total_services'] is String
          ? int.tryParse(json['total_services'])
          : json['total_services'] as int?,
      totalEarnings: json['total_earnings']?.toString(),
      totalWaitingCharges: json['total_waiting_charges'] is String
          ? int.tryParse(json['total_waiting_charges'])
          : json['total_waiting_charges'] as int?,
      services: json['services'] != null
          ? (json['services'] as List)
          .map((service) => ServiceEarning.fromJson(service))
          .toList()
          : null,
    );
  }
}

class ServiceEarning {
  final Service? service;
  final String? baseFare;
  final int? waitingMinutes;
  final int? waitingCharges;
  final String? totalAmount;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? endedAt;

  ServiceEarning({
    this.service,
    this.baseFare,
    this.waitingMinutes,
    this.waitingCharges,
    this.totalAmount,
    this.startedAt,
    this.arrivedAt,
    this.endedAt,
  });

  factory ServiceEarning.fromJson(Map<String, dynamic> json) {
    return ServiceEarning(
      service: json['service'] != null
          ? Service.fromJson(json['service'])
          : null,
      baseFare: json['base_fare']?.toString(),
      waitingMinutes: json['waiting_minutes'] is String
          ? int.tryParse(json['waiting_minutes'])
          : json['waiting_minutes'] as int?,
      waitingCharges: json['waiting_charges'] is String
          ? int.tryParse(json['waiting_charges'])
          : json['waiting_charges'] as int?,
      totalAmount: json['total_amount']?.toString(),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'])
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
    );
  }

  String getRelativeTime() {
    if (startedAt == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(startedAt!);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String getFormattedDate() {
    if (startedAt == null) return 'N/A';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${startedAt!.day} ${months[startedAt!.month - 1]} ${startedAt!.year}';
  }

  String getFormattedTime() {
    if (startedAt == null) return 'N/A';
    final hour = startedAt!.hour > 12 ? startedAt!.hour - 12 : startedAt!.hour;
    final amPm = startedAt!.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${startedAt!.minute.toString().padLeft(2, '0')} $amPm';
  }
}

class Service {
  final String? id;
  final String? title;
  final String? category;
  final String? service;
  final String? description;
  final String? userId;
  final String? budget;
  final String? maxBudget;
  final String? tenure;
  final String? scheduleDate;
  final String? scheduleTime;
  final String? serviceType;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? serviceMode;
  final int? durationValue;
  final String? durationUnit;
  final String? serviceDays;
  final String? startDate;
  final String? endDate;
  final int? extraTimeMinutes;
  final String? assignedProviderId;
  final String? status;
  final String? reason;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? endedAt;
  final DateTime? confirmedAt;
  final String? startOtp;
  final String? endOtp;
  final String? paymentMethod;
  final String? paymentType;
  final String? finalAmount;
  final Map<String, dynamic>? dynamicFields;
  final String? cancelledBy;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isCalculate;

  Service({
    this.id,
    this.title,
    this.category,
    this.service,
    this.description,
    this.userId,
    this.budget,
    this.maxBudget,
    this.tenure,
    this.scheduleDate,
    this.scheduleTime,
    this.serviceType,
    this.location,
    this.latitude,
    this.longitude,
    this.serviceMode,
    this.durationValue,
    this.durationUnit,
    this.serviceDays,
    this.startDate,
    this.endDate,
    this.extraTimeMinutes,
    this.assignedProviderId,
    this.status,
    this.reason,
    this.startedAt,
    this.arrivedAt,
    this.endedAt,
    this.confirmedAt,
    this.startOtp,
    this.endOtp,
    this.paymentMethod,
    this.paymentType,
    this.finalAmount,
    this.dynamicFields,
    this.cancelledBy,
    this.cancelReason,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.isCalculate,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      category: json['category']?.toString(),
      service: json['service']?.toString(),
      description: json['description']?.toString(),
      userId: json['user_id']?.toString(),
      budget: json['budget']?.toString(),
      maxBudget: json['max_budget']?.toString(),
      tenure: json['tenure']?.toString(),
      scheduleDate: json['schedule_date']?.toString(),
      scheduleTime: json['schedule_time']?.toString(),
      serviceType: json['service_type']?.toString(),
      location: json['location']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      serviceMode: json['service_mode']?.toString(),
      durationValue: json['duration_value'] is String
          ? int.tryParse(json['duration_value'])
          : json['duration_value'] as int?,
      durationUnit: json['duration_unit']?.toString(),
      serviceDays: json['service_days']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      extraTimeMinutes: json['extra_time_minutes'] is String
          ? int.tryParse(json['extra_time_minutes'])
          : json['extra_time_minutes'] as int?,
      assignedProviderId: json['assigned_provider_id']?.toString(),
      status: json['status']?.toString(),
      reason: json['reason']?.toString(),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'])
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'])
          : null,
      startOtp: json['start_otp']?.toString(),
      endOtp: json['end_otp']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentType: json['payment_type']?.toString(),
      finalAmount: json['final_amount']?.toString(),
      dynamicFields: json['dynamic_fields'],
      cancelledBy: json['cancelled_by']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isCalculate: json['is_calculate'],
    );
  }
}