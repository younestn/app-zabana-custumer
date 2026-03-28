import 'dart:convert';
class ChosenShippingMethodModel {
  int? _id;
  String? _cartGroupId;
  int? _shippingMethodId;
  double? _shippingCost;
  String? _createdAt;
  String? _updatedAt;
  int? _isCheckItemExist;
  Map<String, dynamic>? _extraData;

  ChosenShippingMethodModel({
    int? id,
    String? cartGroupId,
    int? shippingMethodId,
    double? shippingCost,
    String? createdAt,
    String? updatedAt,
    int? isCheckItemExist,
    Map<String, dynamic>? extraData,
  }) {
    _id = id;
    _cartGroupId = cartGroupId;
    _shippingMethodId = shippingMethodId;
    _shippingCost = shippingCost;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _isCheckItemExist = isCheckItemExist;
    _extraData = extraData;
  }

  int? get id => _id;
  String? get cartGroupId => _cartGroupId;
  int? get shippingMethodId => _shippingMethodId;
  double? get shippingCost => _shippingCost;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get isCheckItemExist => _isCheckItemExist;
  Map<String, dynamic>? get extraData => _extraData;

  ChosenShippingMethodModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _cartGroupId = json['cart_group_id'];
    _shippingMethodId = int.tryParse(json['shipping_method_id'].toString());
    _shippingCost = double.tryParse(json['shipping_cost'].toString());
    _createdAt = json['created_at']?.toString();
    _updatedAt = json['updated_at']?.toString();
    _isCheckItemExist = json['is_check_item_exist'];
  final dynamic rawExtraData = json['extra_data'];

if (rawExtraData is Map<String, dynamic>) {
  _extraData = rawExtraData;
} else if (rawExtraData is Map) {
  _extraData = Map<String, dynamic>.from(rawExtraData);
} else if (rawExtraData is String && rawExtraData.isNotEmpty) {
  try {
    final dynamic decoded = jsonDecode(rawExtraData);
    if (decoded is Map<String, dynamic>) {
      _extraData = decoded;
    } else if (decoded is Map) {
      _extraData = Map<String, dynamic>.from(decoded);
    } else {
      _extraData = null;
    }
  } catch (_) {
    _extraData = null;
  }
} else {
  _extraData = null;
}
  }
}