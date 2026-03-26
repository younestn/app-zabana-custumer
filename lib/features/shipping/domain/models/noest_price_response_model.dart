class NoestPriceResponseModel {
  double? price;
  String? currency;
  String? deliveryType;
  String? estimatedDays;

  NoestPriceResponseModel({
    this.price,
    this.currency,
    this.deliveryType,
    this.estimatedDays,
  });

  NoestPriceResponseModel.fromJson(Map<String, dynamic> json) {
    price = double.tryParse(json['price'].toString());
    currency = json['currency']?.toString();
    deliveryType = json['delivery_type']?.toString();
    estimatedDays = json['estimated_days']?.toString();
  }
}