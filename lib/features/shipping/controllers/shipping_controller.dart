import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/models/selected_shipping_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/chosen_shipping_method.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_price_response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_station_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_wilaya_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/services/shipping_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class ShippingController extends ChangeNotifier {
  final ShippingServiceInterface shippingServiceInterface;
  ShippingController({required this.shippingServiceInterface});

  List<ChosenShippingMethodModel> _chosenShippingList = [];
  List<ChosenShippingMethodModel> get chosenShippingList => _chosenShippingList;

  List<ShippingModel>? _shippingList;
  List<ShippingModel>? get shippingList => _shippingList;

  List<bool> isSelectedList = [];
  double amount = 0.0;
  bool isSelectAll = true;
  bool _isLoading = false;
  CartModel? cart;
  String? _updateQuantityErrorText;
  String? get addOrderStatusErrorText => _updateQuantityErrorText;
  bool get isLoading => _isLoading;

  final List<int> _chosenShippingMethodIndex = [];
  List<int> get chosenShippingMethodIndex => _chosenShippingMethodIndex;

  Future<void> getShippingMethod(BuildContext context, List<List<CartModel>> cartProdList) async {
    _isLoading = true;
    Provider.of<CartController>(context, listen: false).getCartDataLoaded();

    List<int?> sellerIdList = [];
    List<String?> sellerTypeList = [];
    List<String?> groupList = [];
    _shippingList = [];

    for (List<CartModel> element in cartProdList) {
      sellerIdList.add(element[0].sellerId);
      sellerTypeList.add(element[0].sellerIs);
      groupList.add(element[0].cartGroupId);
      _shippingList!.add(ShippingModel(-1, element[0].cartGroupId, []));
    }

    await getChosenShippingMethod(context);

    for (int i = 0; i < sellerIdList.length; i++) {
      ApiResponseModel apiResponse = await shippingServiceInterface.getShippingMethod(sellerIdList[i], sellerTypeList[i]);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        List<ShippingMethodModel> shippingMethodList = [];
        apiResponse.response!.data.forEach((shipping) {
          shippingMethodList.add(ShippingMethodModel.fromJson(shipping));
        });

        _shippingList![i].shippingMethodList = [];
        _shippingList![i].shippingMethodList!.addAll(shippingMethodList);

        int index = -1;
        int? shipId = -1;

        for (ChosenShippingMethodModel cs in _chosenShippingList) {
          if (cs.cartGroupId == groupList[i]) {
            shipId = cs.shippingMethodId;
            break;
          }
        }

        if (shipId != -1) {
          for (int j = 0; j < _shippingList![i].shippingMethodList!.length; j++) {
            if (_shippingList![i].shippingMethodList![j].id == shipId) {
              index = j;
              break;
            }
          }
        }

        _shippingList![i].shippingIndex = index;
      } else {
        ApiChecker.checkApi(apiResponse);
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAdminShippingMethodList(BuildContext context) async {
    _isLoading = true;
    Provider.of<CartController>(context, listen: false).getCartDataLoaded();
    _shippingList = [];
    await getChosenShippingMethod(context);

    ApiResponseModel apiResponse = await shippingServiceInterface.getShippingMethod(1, 'admin');
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _shippingList!.add(ShippingModel(-1, '', []));
      List<ShippingMethodModel> shippingMethodList = [];
      apiResponse.response!.data.forEach((shipping) {
        shippingMethodList.add(ShippingMethodModel.fromJson(shipping));
      });

      _shippingList![0].shippingMethodList = [];
      _shippingList![0].shippingMethodList!.addAll(shippingMethodList);

      int index = -1;
      if (_chosenShippingList.isNotEmpty) {
        for (int j = 0; j < _shippingList![0].shippingMethodList!.length; j++) {
          if (_shippingList![0].shippingMethodList![j].id == _chosenShippingList[0].shippingMethodId) {
            index = j;
            break;
          }
        }
      }

      _shippingList![0].shippingIndex = index;
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getChosenShippingMethod(BuildContext context) async {
    ApiResponseModel apiResponse = await shippingServiceInterface.getChosenShippingMethod();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _chosenShippingList = [];
      apiResponse.response!.data.forEach((shipping) {
        _chosenShippingList.add(ChosenShippingMethodModel.fromJson(shipping));
      });
      notifyListeners();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setSelectedShippingMethod(int? index, int sellerIndex) {
    _shippingList![sellerIndex].shippingIndex = index;
    notifyListeners();
  }

  void initShippingMethodIndexList(int length) {
    _shippingList = [];
    for (int i = 0; i < length; i++) {
      _shippingList!.add(ShippingModel(0, '', null));
    }
  }

  Future addShippingMethod({
    required BuildContext context,
    required ShippingMethodModel method,
    required String groupId,
    required int? sellerId,
    required String? sellerType,
  }) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> body;

    if ((method.isNoest ?? 0) == 1) {
      body = {
        'id': method.id,
        'cart_group_id': groupId,
        'seller_id': sellerId,
        'seller_is': sellerType,
        'shipping_company': method.companyName ?? method.title,
        'delivery_type': _selectedDeliveryTypeMap[groupId] ?? method.deliveryType,
        'wilaya_id': _selectedWilayaIdMap[groupId],
        'wilaya_name': _selectedWilayaNameMap[groupId],
        'station_code': _selectedStationCodeMap[groupId],
        'station_name': _selectedStationNameMap[groupId],
        'baladiya_name': _selectedBaladiyaNameMap[groupId],
        'estimated_days': _estimatedDaysMap[groupId] ?? method.estimatedDays,
        'shipping_cost': _pendingShippingCostMap[groupId] ?? method.cost ?? 0,
        'is_noest': 1,
      };
    } else {
      body = {
        'id': method.id,
        'cart_group_id': groupId,
        'seller_id': sellerId,
        'seller_is': sellerType,
        'shipping_company': method.companyName ?? method.title,
        'delivery_type': method.deliveryType ?? 'home_delivery',
        'wilaya_id': null,
        'wilaya_name': null,
        'station_code': null,
        'station_name': null,
        'baladiya_name': null,
        'estimated_days': method.estimatedDays ?? method.duration,
        'shipping_cost': method.cost ?? 0,
        'is_noest': 0,
      };
    }

    final apiResponse = await shippingServiceInterface.addShippingMethodWithData(body);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      await getChosenShippingMethod(Get.context!);
      await Provider.of<CartController>(Get.context!, listen: false).getCartData(Get.context!);

      if (context.mounted) {
        Navigator.pop(context);
      }

      showCustomSnackBar(
        getTranslated('shipping_method_added_successfully', Get.context!),
        Get.context!,
        isError: false,
      );
    } else {
      if (context.mounted) {
        Navigator.pop(context);
      }
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  String? _selectedShippingType;
  String? get selectedShippingType => _selectedShippingType;

  final List<SelectedShippingType> _selectedShippingTypeList = [];
  List<SelectedShippingType> get selectedShippingTypeList => _selectedShippingTypeList;

  ChosenShippingMethodModel? getChosenShippingByGroupId(String? groupId) {
    if (groupId == null) {
      return null;
    }

    try {
      return _chosenShippingList.firstWhere((item) => item.cartGroupId == groupId);
    } catch (e) {
      return null;
    }
  }

  ShippingMethodModel? getSelectedMethodBySellerIndex(int sellerIndex) {
    if (_shippingList == null || sellerIndex >= _shippingList!.length) {
      return null;
    }

    final int? selectedIndex = _shippingList![sellerIndex].shippingIndex;
    final List<ShippingMethodModel>? methodList = _shippingList![sellerIndex].shippingMethodList;

    if (selectedIndex == null || selectedIndex < 0 || methodList == null || selectedIndex >= methodList.length) {
      return null;
    }

    return methodList[selectedIndex];
  }

  double getTotalChosenShippingCost() {
    double total = 0;
    for (final ChosenShippingMethodModel item in _chosenShippingList) {
      total += item.shippingCost ?? 0;
    }
    return total;
  }

  String getShippingMethodName(ShippingMethodModel? method) {
    if (method == null) {
      return '';
    }

    if ((method.isNoest ?? 0) == 1) {
      final String company = (method.companyName?.isNotEmpty ?? false)
          ? method.companyName!
          : ((method.providerName?.isNotEmpty ?? false) ? method.providerName! : (method.title ?? 'NOEST'));

      final String deliveryLabel = (method.deliveryTypeLabel?.isNotEmpty ?? false)
          ? method.deliveryTypeLabel!
          : ((method.deliveryType == 'desk_delivery') ? 'Desk Delivery' : 'Home Delivery');

      return '$company - $deliveryLabel';
    }

    if ((method.companyName?.isNotEmpty ?? false)) {
      return method.companyName!;
    }

    if ((method.providerName?.isNotEmpty ?? false)) {
      return method.providerName!;
    }

    return method.title ?? '';
  }

  String getShippingMethodDuration(ShippingMethodModel? method) {
    if (method == null) {
      return '';
    }

    if ((method.isNoest ?? 0) == 1) {
      if ((method.estimatedDays?.isNotEmpty ?? false)) {
        return method.estimatedDays!;
      }
      if ((method.duration?.isNotEmpty ?? false)) {
        return method.duration!;
      }
      if ((method.deliveryTypeLabel?.isNotEmpty ?? false)) {
        return method.deliveryTypeLabel!;
      }
      return '';
    }

    if ((method.deliveryTypeLabel?.isNotEmpty ?? false)) {
      return method.deliveryTypeLabel!;
    }

    if ((method.estimatedDays?.isNotEmpty ?? false)) {
      return method.estimatedDays!;
    }

    return method.duration ?? '';
  }

  final Map<String, List<NoestWilayaModel>> _noestWilayaMap = {};
  final Map<String, List<NoestStationModel>> _noestStationMap = {};
  final Map<String, int?> _selectedWilayaIdMap = {};
  final Map<String, String?> _selectedWilayaNameMap = {};
  final Map<String, String?> _selectedDeliveryTypeMap = {};
  final Map<String, String?> _selectedStationCodeMap = {};
  final Map<String, String?> _selectedStationNameMap = {};
  final Map<String, String?> _selectedBaladiyaNameMap = {};
  final Map<String, double> _pendingShippingCostMap = {};
  final Map<String, String?> _estimatedDaysMap = {};

  Map<String, List<NoestWilayaModel>> get noestWilayaMap => _noestWilayaMap;
  Map<String, List<NoestStationModel>> get noestStationMap => _noestStationMap;
  Map<String, double> get pendingShippingCostMap => _pendingShippingCostMap;

  List<NoestWilayaModel> getNoestWilayasByGroupId(String groupId) {
    return _noestWilayaMap[groupId] ?? [];
  }

  List<NoestStationModel> getNoestStationsByGroupId(String groupId) {
    return _noestStationMap[groupId] ?? [];
  }

  int? getSelectedWilayaId(String groupId) {
    return _selectedWilayaIdMap[groupId];
  }

  String? getSelectedWilayaName(String groupId) {
    return _selectedWilayaNameMap[groupId];
  }

  String getSelectedDeliveryType(String groupId, {String fallback = 'home_delivery'}) {
    return _selectedDeliveryTypeMap[groupId] ?? fallback;
  }

  String? getSelectedStationCode(String groupId) {
    return _selectedStationCodeMap[groupId];
  }

  String? getSelectedStationName(String groupId) {
    return _selectedStationNameMap[groupId];
  }

  String? getSelectedBaladiyaName(String groupId) {
    return _selectedBaladiyaNameMap[groupId];
  }

  String? getEstimatedDays(String groupId) {
    return _estimatedDaysMap[groupId];
  }

  double getPendingShippingCost(String groupId, {double fallback = 0}) {
    return _pendingShippingCostMap[groupId] ?? fallback;
  }

  void setSelectedDeliveryType(String groupId, String value) {
    _selectedDeliveryTypeMap[groupId] = value;
    _pendingShippingCostMap[groupId] = 0;

    if (value == 'home_delivery') {
      _selectedStationCodeMap[groupId] = null;
      _selectedStationNameMap[groupId] = null;
    }

    notifyListeners();
  }

  void setSelectedWilaya(String groupId, int? wilayaId, String? wilayaName) {
    _selectedWilayaIdMap[groupId] = wilayaId;
    _selectedWilayaNameMap[groupId] = wilayaName;
    _selectedStationCodeMap[groupId] = null;
    _selectedStationNameMap[groupId] = null;
    _pendingShippingCostMap[groupId] = 0;
    notifyListeners();
  }

  void setSelectedStation(String groupId, String? stationCode, String? stationName) {
    _selectedStationCodeMap[groupId] = stationCode;
    _selectedStationNameMap[groupId] = stationName;
    notifyListeners();
  }

  void setSelectedBaladiyaName(String groupId, String? value) {
    _selectedBaladiyaNameMap[groupId] = value?.trim();
    notifyListeners();
  }

  void resetNoestSelection(String groupId) {
    _selectedWilayaIdMap.remove(groupId);
    _selectedWilayaNameMap.remove(groupId);
    _selectedDeliveryTypeMap.remove(groupId);
    _selectedStationCodeMap.remove(groupId);
    _selectedStationNameMap.remove(groupId);
    _selectedBaladiyaNameMap.remove(groupId);
    _pendingShippingCostMap.remove(groupId);
    _estimatedDaysMap.remove(groupId);
    _noestStationMap.remove(groupId);
    notifyListeners();
  }

  void hydrateNoestSelectionFromChosen({
    required String groupId,
    required ShippingMethodModel method,
    ChosenShippingMethodModel? chosenShipping,
  }) {
    final Map<String, dynamic> extra = chosenShipping?.extraData ?? {};

    if ((extra['is_noest'] == 1 || extra['is_noest'] == '1') || (method.isNoest ?? 0) == 1) {
      _selectedDeliveryTypeMap[groupId] =
          extra['delivery_type']?.toString() ?? method.deliveryType ?? 'home_delivery';

      _selectedWilayaIdMap[groupId] = _toInt(extra['wilaya_id']);
      _selectedWilayaNameMap[groupId] = extra['wilaya_name']?.toString();
      _selectedStationCodeMap[groupId] = extra['station_code']?.toString();
      _selectedStationNameMap[groupId] = extra['station_name']?.toString();
      _selectedBaladiyaNameMap[groupId] = extra['baladiya_name']?.toString();
      _estimatedDaysMap[groupId] = extra['estimated_days']?.toString() ?? method.estimatedDays;
      _pendingShippingCostMap[groupId] = chosenShipping?.shippingCost ?? method.cost ?? 0;
    } else {
      _selectedDeliveryTypeMap[groupId] = method.deliveryType ?? 'home_delivery';
      _estimatedDaysMap[groupId] = method.estimatedDays ?? method.duration;
      _pendingShippingCostMap[groupId] = chosenShipping?.shippingCost ?? method.cost ?? 0;
    }

    notifyListeners();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> loadNoestWilayas({
    required BuildContext context,
    required int? sellerId,
    required String? sellerType,
    required String groupId,
  }) async {
    final apiResponse = await shippingServiceInterface.getNoestWilayas(sellerId, sellerType);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _noestWilayaMap[groupId] = [];
      apiResponse.response!.data.forEach((item) {
        _noestWilayaMap[groupId]!.add(NoestWilayaModel.fromJson(item));
      });
      notifyListeners();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }

  Future<void> loadNoestStations({
    required BuildContext context,
    required int? sellerId,
    required String? sellerType,
    required int wilayaId,
    required String groupId,
  }) async {
    final apiResponse = await shippingServiceInterface.getNoestStations(sellerId, sellerType, wilayaId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _noestStationMap[groupId] = [];
      apiResponse.response!.data.forEach((item) {
        _noestStationMap[groupId]!.add(NoestStationModel.fromJson(item));
      });
      notifyListeners();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }

  Future<void> calculateNoestPrice({
    required BuildContext context,
    required int? sellerId,
    required String? sellerType,
    required String groupId,
  }) async {
    final body = {
      'seller_id': sellerId,
      'seller_is': sellerType,
      'cart_group_id': groupId,
      'delivery_type': _selectedDeliveryTypeMap[groupId],
      'wilaya_id': _selectedWilayaIdMap[groupId],
      'station_code': _selectedStationCodeMap[groupId],
    };

    final apiResponse = await shippingServiceInterface.getNoestPrice(body);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final response = NoestPriceResponseModel.fromJson(apiResponse.response!.data);
      _pendingShippingCostMap[groupId] = response.price ?? 0;
      _estimatedDaysMap[groupId] = response.estimatedDays;
      notifyListeners();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }
}