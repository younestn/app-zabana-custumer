abstract class ShippingServiceInterface {
  Future<dynamic> getShippingMethod(int? sellerId, String? type);
  Future<dynamic> addShippingMethod(int? id, String? cartGroupId);
  Future<dynamic> addShippingMethodWithData(Map<String, dynamic> body);
  Future<dynamic> getChosenShippingMethod();
  Future<dynamic> getNoestWilayas(int? sellerId, String? type);
  Future<dynamic> getNoestStations(int? sellerId, String? type, int? wilayaId);
  Future<dynamic> getNoestPrice(Map<String, dynamic> body);
}