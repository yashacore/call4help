class SubcategoryResponse {
  final String message;
  final int total;
  final List<Subcategory> subcategories;

  SubcategoryResponse({
    required this.message,
    required this.total,
    required this.subcategories,
  });

  factory SubcategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubcategoryResponse(
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      subcategories:
          (json['subcategories'] as List?)
              ?.map((item) => Subcategory.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final String billingType;
  final String hourlyRate;
  final String dailyRate;
  final String weeklyRate;
  final String monthlyRate;
  final String? icon;
  final String gst;
  final String tds;
  final String commission;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExplicitSite>? explicitSite;
  final List<ImplicitSite>? implicitSite;
  final bool isSubcategory;
  final List<Field> fields;

  Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.billingType,
    required this.hourlyRate,
    required this.dailyRate,
    required this.weeklyRate,
    required this.monthlyRate,
    this.icon,
    required this.gst,
    required this.tds,
    required this.commission,
    required this.createdAt,
    required this.updatedAt,
    this.explicitSite,
    this.implicitSite,
    required this.isSubcategory,
    required this.fields,
  });

  Subcategory copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? billingType,
    String? hourlyRate,
    String? dailyRate,
    String? weeklyRate,
    String? monthlyRate,
    String? icon,
    String? gst,
    String? tds,
    String? commission,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ExplicitSite>? explicitSite,
    List<ImplicitSite>? implicitSite,
    bool? isSubcategory,
    List<Field>? fields,
  }) {
    return Subcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      billingType: billingType ?? this.billingType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      weeklyRate: weeklyRate ?? this.weeklyRate,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      icon: icon ?? this.icon,
      gst: gst ?? this.gst,
      tds: tds ?? this.tds,
      commission: commission ?? this.commission,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      explicitSite: explicitSite ?? this.explicitSite,
      implicitSite: implicitSite ?? this.implicitSite,
      isSubcategory: isSubcategory ?? this.isSubcategory,
      fields: fields ?? this.fields,
    );
  }

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      billingType: json['billing_type'] ?? '',
      hourlyRate: json['hourly_rate'] ?? '0.00',
      dailyRate: json['daily_rate'] ?? '0.00',
      weeklyRate: json['weekly_rate'] ?? '0.00',
      monthlyRate: json['monthly_rate'] ?? '0.00',
      icon: json['icon'],
      gst: json['gst'] ?? '0.00',
      tds: json['tds'] ?? '0.00',
      commission: json['commission'] ?? '0.00',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      explicitSite: json['explicit_site'] != null
          ? (json['explicit_site'] as List)
                .map((item) => ExplicitSite.fromJson(item))
                .toList()
          : null,
      implicitSite: json['implicit_site'] != null
          ? (json['implicit_site'] as List)
                .map((item) => ImplicitSite.fromJson(item))
                .toList()
          : null,
      isSubcategory: json['is_subcategory'] ?? false,
      fields:
          (json['fields'] as List?)
              ?.map((item) => Field.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ExplicitSite {
  final String name;
  final String? image;

  ExplicitSite({required this.name, this.image});

  factory ExplicitSite.fromJson(Map<String, dynamic> json) {
    return ExplicitSite(name: json['name'] ?? '', image: json['image']);
  }
}

class ImplicitSite {
  final String name;
  final String? image;

  ImplicitSite({required this.name, this.image});

  factory ImplicitSite.fromJson(Map<String, dynamic> json) {
    return ImplicitSite(name: json['name'] ?? '', image: json['image']);
  }
}

class Field {
  final int id;
  final int subcategoryId;
  final String fieldName;
  final String fieldType;
  final List<String>? options;
  final bool isRequired;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCalculate;

  Field({
    required this.id,
    required this.subcategoryId,
    required this.fieldName,
    required this.fieldType,
    this.options,
    required this.isRequired,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.isCalculate,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] ?? 0,
      subcategoryId: json['subcategory_id'] ?? 0,
      fieldName: json['field_name'] ?? '',
      fieldType: json['field_type'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      isRequired: json['is_required'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isCalculate: json['is_calculate'] ?? false,
    );
  }
}
