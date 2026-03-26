class ShippingMethodModel {
  int? id;
  int? creatorId;
  String? creatorType;
  String? title;
  double? cost;
  String? duration;
  String? createdAt;
  String? updatedAt;

  String? providerName;
  String? serviceKey;
  String? logo;
  String? deliveryType;
  String? deliveryTypeLabel;
  String? companyName;
  String? estimatedDays;
  int? isThirdParty;
  int? isNoest;
  String? stationCode;

  ShippingMethodModel({
    this.id,
    this.creatorId,
    this.creatorType,
    this.title,
    this.cost,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.providerName,
    this.serviceKey,
    this.logo,
    this.deliveryType,
    this.deliveryTypeLabel,
    this.companyName,
    this.estimatedDays,
    this.isThirdParty,
    this.isNoest,
    this.stationCode,
  });

  ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    creatorId = _toInt(json['creator_id']);
    creatorType = json['creator_type']?.toString();
    title = json['title']?.toString();
    cost = _toDouble(json['cost']);
    duration = json['duration']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    providerName = json['provider_name']?.toString();
    serviceKey = json['service_key']?.toString();
    logo = json['logo']?.toString();
    deliveryType = json['delivery_type']?.toString();
    deliveryTypeLabel = json['delivery_type_label']?.toString();
    companyName = json['company_name']?.toString();
    estimatedDays = json['estimated_days']?.toString();
    isThirdParty = _toInt(json['is_third_party']);
    isNoest = _toInt(json['is_noest']);
    stationCode = json['station_code']?.toString();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}