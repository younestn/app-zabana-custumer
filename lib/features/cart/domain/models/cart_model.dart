import 'package:flutter_sixvalley_ecommerce/data/model/image_full_url.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/seller_model.dart';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
} 
class CartModel {
  int? id;
  int? productId;
  String? image;
  String? name;
  String? thumbnail;
  ImageFullUrl? thumbnailFullUrl;
  int? sellerId;
  String? sellerIs;
  String? seller;
  double? price;
  double? discountedPrice;
  int? quantity;
  int? maxQuantity;
  String? variant;
  String? color;
  Variation? variation;
  double? discount;
  String? discountType;
  double? tax;
  String? taxModel;
  String? taxType;
  int? shippingMethodId;
  String? cartGroupId;
  String? shopInfo;
  List<ChoiceOptions>? choiceOptions;
  List<int>? variationIndexes;
  double?  shippingCost;
  String? shippingType;
  int? minimumOrderQuantity;
  ProductInfo? productInfo;
  String? productType;
  String? slug;
  double? minimumOrderAmountInfo;
  FreeDeliveryOrderAmount? freeDeliveryOrderAmount;
  bool? increment;
  bool? decrement;
  Shop? shop;
  int? isProductAvailable;
  bool? isChecked;
  bool? isGroupChecked;
  bool? isGroupItemChecked;




  CartModel(
      this.id,
      this.productId,
      this.thumbnail,
      this.thumbnailFullUrl,
      this.name,
      this.seller,
      this.price,
      this.discountedPrice,
      this.quantity,
      this.maxQuantity,
      this.variant,
      this.color,
      this.variation,
      this.discount,
      this.discountType,
      this.tax,
      this.taxModel,
      this.taxType,
      this.shippingMethodId,
      this.cartGroupId,
      this.sellerId,
      this.sellerIs,
      this.image,
      this.shopInfo,
      this.choiceOptions,
      this.variationIndexes,
      this.shippingCost,
      this.minimumOrderQuantity,
      this.productType,
      this.slug,
      this.minimumOrderAmountInfo,
      this.freeDeliveryOrderAmount,
      this.increment,
      this.decrement,
      this.shop,
      this.isProductAvailable,
      this.isChecked,
      this.isGroupChecked,
      this.isGroupItemChecked
      );


CartModel.fromJson(Map<String, dynamic> json) {
  id = _toInt(json['id']);
  productId = _toInt(json['product_id']);
  name = json['name'];
  seller = json['seller'];
  thumbnail = json['thumbnail'];
  sellerId = _toInt(json['seller_id']);
  sellerIs = json['seller_is'];
  image = json['image'];
  price = _toDouble(json['price']) ?? 0;
  discountedPrice = _toDouble(json['discounted_price']);
  quantity = _toInt(json['quantity']) ?? 0;
  maxQuantity = _toInt(json['max_quantity']);
  variant = json['variant'];
  color = json['color'];
  variation = json['variation'] != null ? Variation.fromJson(json['variation']) : null;
  discount = _toDouble(json['discount']) ?? 0;
  discountType = json['discount_type'];
  tax = _toDouble(json['tax']) ?? 0;
  taxModel = json['tax_model'];
  taxType = json['tax_type'];
  shippingMethodId = _toInt(json['shipping_method_id']);
  cartGroupId = json['cart_group_id']?.toString();
  shopInfo = json['shop_info'];

  if (json['choice_options'] != null) {
    choiceOptions = [];
    json['choice_options'].forEach((v) {
      choiceOptions!.add(ChoiceOptions.fromJson(v));
    });
  }

  variationIndexes = json['variation_indexes'] != null ? json['variation_indexes'].cast<int>() : [];

  shippingCost = _toDouble(json['shipping_cost']);
  if (json['shipping_type'] != null) {
    shippingType = json['shipping_type'];
  }

  productInfo = json['product'] != null ? ProductInfo.fromJson(json['product']) : null;
  productType = json['product_type'];
  slug = json['slug'];
  minimumOrderAmountInfo = _toDouble(json['minimum_order_amount_info']);

  increment = false;
  decrement = false;

  freeDeliveryOrderAmount = json['free_delivery_order_amount'] != null
      ? FreeDeliveryOrderAmount.fromJson(json['free_delivery_order_amount'])
      : null;

  shop = json['shop'] != null ? Shop.fromJson(json['shop'], isAdminProduct: json['seller_is'] == 'admin') : null;

  if (json["is_product_available"] != null) {
    isProductAvailable = _toInt(json["is_product_available"]) ?? 1;
  } else {
    isProductAvailable = 1;
  }

  if (json['is_checked'] != null) {
    isChecked = json['is_checked'] == 1 ? true : false;
  } else {
    isChecked = false;
  }

  thumbnailFullUrl = json['thumbnail_full_url'] != null
      ? ImageFullUrl.fromJson(json['thumbnail_full_url'])
      : null;

  isGroupChecked = false;
  isGroupItemChecked = false;
}


}

class ProductInfo {
  int? minimumOrderQty;
  int? totalCurrentStock;
  ImageFullUrl? thumbnailFullUrl;

  ProductInfo({ this.minimumOrderQty, this.totalCurrentStock});

ProductInfo.fromJson(Map<String, dynamic> json) {
  minimumOrderQty = _toInt(json['minimum_order_qty']);
  totalCurrentStock = _toInt(json['total_current_stock']);
  thumbnailFullUrl = json['thumbnail_full_url'] != null
      ? ImageFullUrl.fromJson(json['thumbnail_full_url'])
      : null;
}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['minimum_order_qty'] = minimumOrderQty;
    data['total_current_stock'] = totalCurrentStock;
    return data;
  }
}

class FreeDeliveryOrderAmount {
  int? status;
  double? amount;
  int? percentage;
  double? shippingCostSaved;
  double? amountNeed;

  FreeDeliveryOrderAmount({
    this.status,
    this.amount,
    this.percentage,
    this.shippingCostSaved,
    this.amountNeed,
  });

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

FreeDeliveryOrderAmount.fromJson(Map<String, dynamic> json) {
  status = _toInt(json['status']);
  amount = _toDouble(json['amount']);
  percentage = _toInt(json['percentage']);
  shippingCostSaved = _toDouble(json['shipping_cost_saved']);
  amountNeed = _toDouble(json['amount_need']);
}
}



class CartModelBody{
  int? productId;
  String? variant;
  String? color;
  Variation? variation;
  int? quantity;
  String? variantKey;
  double? digitalVariantPrice;

  CartModelBody(
    {this.productId,
      this.variant,
      this.color,
      this.variation,
      this.quantity,
      this.variantKey,
      this.digitalVariantPrice});
}

class ReferralAmount {
  double? amount;

  ReferralAmount({this.amount});

  ReferralAmount.fromJson(Map<String, dynamic> json) {
    amount = double.tryParse(json['amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    return data;
  }
}
