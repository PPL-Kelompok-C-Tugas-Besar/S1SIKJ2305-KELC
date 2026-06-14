class Voucher {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minimumPurchase;
  final double maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumPurchase = 0.0,
    this.maxDiscount = 0.0,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      discountType: json['discount_type'] ?? 'fixed',
      discountValue: json['discount_value'] != null ? double.parse(json['discount_value'].toString()) : 0.0,
      minimumPurchase: json['minimum_purchase'] != null ? double.parse(json['minimum_purchase'].toString()) : 0.0,
      maxDiscount: json['max_discount'] != null ? double.parse(json['max_discount'].toString()) : 0.0,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'].toString()) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'].toString()) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'minimum_purchase': minimumPurchase,
      'max_discount': maxDiscount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
}
