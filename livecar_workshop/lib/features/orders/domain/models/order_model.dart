class OrderModel {
  final String id;
  final String workshopId;
  final String? customerId;
  final String status;
  final String? vehicleInfo;
  final String? problemDescription;
  final double? totalPrice;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.workshopId,
    this.customerId,
    required this.status,
    this.vehicleInfo,
    this.problemDescription,
    this.totalPrice,
    this.customerName,
    this.customerPhone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // profiles join (customer_id FK -> profiles.id)
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return OrderModel(
      id: json['id'] as String,
      workshopId: json['workshop_id'] as String,
      customerId: json['customer_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      vehicleInfo: json['vehicle_info'] as String?,
      problemDescription: json['problem_description'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      customerName: profileData?['full_name'] as String?,
      customerPhone: profileData?['phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'workshop_id': workshopId,
    'customer_id': customerId,
    'status': status,
    'vehicle_info': vehicleInfo,
    'problem_description': problemDescription,
    'total_price': totalPrice,
    'notes': notes,
  };

  OrderModel copyWith({
    String? status,
    double? totalPrice,
    String? notes,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id,
      workshopId: workshopId,
      customerId: customerId,
      status: status ?? this.status,
      vehicleInfo: vehicleInfo,
      problemDescription: problemDescription,
      totalPrice: totalPrice ?? this.totalPrice,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
    );
  }
}class OrderModel {
  final String id;
  final String workshopId;
  final String? customerId;
  final String status;
  final String? vehicleInfo;
  final String? problemDescription;
  final double? totalPrice;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.workshopId,
    this.customerId,
    required this.status,
    this.vehicleInfo,
    this.problemDescription,
    this.totalPrice,
    this.customerName,
    this.customerPhone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      workshopId: json['workshop_id'] as String,
      customerId: json['customer_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      vehicleInfo: json['vehicle_info'] as String?,
      problemDescription: json['problem_description'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      customerName: json['users']?['full_name'] as String?,
      customerPhone: json['users']?['phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'workshop_id': workshopId,
    'customer_id': customerId,
    'status': status,
    'vehicle_info': vehicleInfo,
    'problem_description': problemDescription,
    'total_price': totalPrice,
    'notes': notes,
  };

  OrderModel copyWith({
    String? status,
    double? totalPrice,
    String? notes,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id,
      workshopId: workshopId,
      customerId: customerId,
      status: status ?? this.status,
      vehicleInfo: vehicleInfo,
      problemDescription: problemDescription,
      totalPrice: totalPrice ?? this.totalPrice,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
