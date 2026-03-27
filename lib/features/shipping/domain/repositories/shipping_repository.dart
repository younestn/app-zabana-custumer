import 'dart:developer';

import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/repositories/shipping_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';

class ShippingRepository implements ShippingRepositoryInterface {
  final DioClient? dioClient;
  ShippingRepository({required this.dioClient});

String _guestId() {
  try {
    final String guestId =
        Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() ?? '';
    return guestId;
  } catch (_) {
    return '';
  }
}

  String _guestQuery() {
    final String guestId = _guestId();
    if (guestId.isEmpty) {
      return '';
    }
    return '&guest_id=${Uri.encodeQueryComponent(guestId)}';
  }

  @override
  Future<ApiResponseModel> getShippingMethod(int? sellerId, String? type) async {
    try {
      final response = await dioClient!.get('${AppConstants.getShippingMethod}/$sellerId/$type');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> addShippingMethod(int? id, String? cartGroupId) async {
    log('===>${{"id": id, "cart_group_id": cartGroupId}}');
    try {
      final response = await dioClient!.post(
        AppConstants.chooseShippingMethod,
        data: {
          "id": id,
          'guest_id': _guestId(),
          "cart_group_id": cartGroupId,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getChosenShippingMethod() async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.chosenShippingMethod}?guest_id=${Uri.encodeQueryComponent(_guestId())}',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponseModel> getNoestWilayas(int? sellerId, String? type) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.getNoestWilayas}?seller_id=${sellerId ?? ''}&seller_is=${type ?? ''}${_guestQuery()}',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getNoestStations(int? sellerId, String? type, int? wilayaId) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.getNoestStations}?seller_id=${sellerId ?? ''}&seller_is=${type ?? ''}&wilaya_id=${wilayaId ?? ''}${_guestQuery()}',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getNoestPrice(Map<String, dynamic> body) async {
    try {
      body['guest_id'] = _guestId();
      final response = await dioClient!.post(AppConstants.getNoestPrice, data: body);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> addShippingMethodWithData(Map<String, dynamic> body) async {
    try {
      body['guest_id'] = _guestId();
      final response = await dioClient!.post(AppConstants.chooseShippingMethod, data: body);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}