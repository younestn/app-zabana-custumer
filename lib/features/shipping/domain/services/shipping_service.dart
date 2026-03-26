import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/repositories/shipping_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/services/shipping_service_interface.dart';

class ShippingService implements ShippingServiceInterface {
  ShippingRepositoryInterface shippingRepositoryInterface;
  ShippingService({required this.shippingRepositoryInterface});

  @override
  Future addShippingMethod(int? id, String? cartGroupId) async {
    return await shippingRepositoryInterface.addShippingMethod(id, cartGroupId);
  }

  @override
  Future addShippingMethodWithData(Map<String, dynamic> body) async {
    return await shippingRepositoryInterface.addShippingMethodWithData(body);
  }

  @override
  Future getChosenShippingMethod() async {
    return await shippingRepositoryInterface.getChosenShippingMethod();
  }

  @override
  Future getShippingMethod(int? sellerId, String? type) async {
    return await shippingRepositoryInterface.getShippingMethod(sellerId, type);
  }

  @override
  Future getNoestWilayas(int? sellerId, String? type) async {
    return await shippingRepositoryInterface.getNoestWilayas(sellerId, type);
  }

  @override
  Future getNoestStations(int? sellerId, String? type, int? wilayaId) async {
    return await shippingRepositoryInterface.getNoestStations(sellerId, type, wilayaId);
  }

  @override
  Future getNoestPrice(Map<String, dynamic> body) async {
    return await shippingRepositoryInterface.getNoestPrice(body);
  }
}