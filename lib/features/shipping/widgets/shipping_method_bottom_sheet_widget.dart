import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/chosen_shipping_method.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_station_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_wilaya_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ShippingMethodBottomSheetWidget extends StatefulWidget {
  final String? groupId;
  final int? sellerId;
  final String sellerType;
  final int sellerIndex;

  const ShippingMethodBottomSheetWidget({
    super.key,
    required this.groupId,
    required this.sellerId,
    required this.sellerType,
    required this.sellerIndex,
  });

  @override
  State<ShippingMethodBottomSheetWidget> createState() => _ShippingMethodBottomSheetWidgetState();
}

class _ShippingMethodBottomSheetWidgetState extends State<ShippingMethodBottomSheetWidget> {
  int selectedIndex = 0;
  bool _didBootstrap = false;
  final TextEditingController _communeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final shippingController = Provider.of<ShippingController>(context, listen: false);

    if (shippingController.shippingList != null &&
        shippingController.shippingList!.isNotEmpty &&
        widget.sellerIndex < shippingController.shippingList!.length) {
      final int currentIndex = shippingController.shippingList![widget.sellerIndex].shippingIndex ?? 0;
      selectedIndex = currentIndex >= 0 ? currentIndex : 0;
    }
  }

  @override
  void dispose() {
    _communeController.dispose();
    super.dispose();
  }

  String get _groupId => widget.groupId ?? '';

  Future<void> _prepareInitialSelection(
    ShippingController shippingController,
    List<ShippingMethodModel> methodList,
    int effectiveIndex,
  ) async {
    selectedIndex = effectiveIndex;
    shippingController.setSelectedShippingMethod(effectiveIndex, widget.sellerIndex);

    final ShippingMethodModel method = methodList[effectiveIndex];

    if ((method.isNoest ?? 0) != 1) {
      shippingController.resetNoestSelection(_groupId);
      _communeController.clear();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final ChosenShippingMethodModel? chosenShipping =
        shippingController.getChosenShippingByGroupId(_groupId);

    shippingController.hydrateNoestSelectionFromChosen(
      groupId: _groupId,
      method: method,
      chosenShipping: chosenShipping,
    );

    _communeController.text = shippingController.getSelectedBaladiyaName(_groupId) ?? '';

    if (shippingController.getNoestWilayasByGroupId(_groupId).isEmpty) {
      await shippingController.loadNoestWilayas(
        context: context,
        sellerId: widget.sellerId,
        sellerType: widget.sellerType,
        groupId: _groupId,
      );
    }

    final int? selectedWilayaId = shippingController.getSelectedWilayaId(_groupId);
    final String deliveryType = shippingController.getSelectedDeliveryType(
      _groupId,
      fallback: method.deliveryType ?? 'home_delivery',
    );

    if (selectedWilayaId != null &&
        deliveryType == 'desk_delivery' &&
        shippingController.getNoestStationsByGroupId(_groupId).isEmpty) {
      await shippingController.loadNoestStations(
        context: context,
        sellerId: widget.sellerId,
        sellerType: widget.sellerType,
        wilayaId: selectedWilayaId,
        groupId: _groupId,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onMethodSelected(
    ShippingController shippingController,
    List<ShippingMethodModel> methodList,
    int index,
  ) async {
    setState(() {
      selectedIndex = index;
    });

    shippingController.setSelectedShippingMethod(index, widget.sellerIndex);
    final ShippingMethodModel method = methodList[index];

    if ((method.isNoest ?? 0) == 1) {
      shippingController.setSelectedDeliveryType(
        _groupId,
        method.deliveryType ?? 'home_delivery',
      );

      if (shippingController.getNoestWilayasByGroupId(_groupId).isEmpty) {
        await shippingController.loadNoestWilayas(
          context: context,
          sellerId: widget.sellerId,
          sellerType: widget.sellerType,
          groupId: _groupId,
        );
      }

      final int? selectedWilayaId = shippingController.getSelectedWilayaId(_groupId);
      if ((method.deliveryType ?? 'home_delivery') == 'desk_delivery' &&
          selectedWilayaId != null &&
          shippingController.getNoestStationsByGroupId(_groupId).isEmpty) {
        await shippingController.loadNoestStations(
          context: context,
          sellerId: widget.sellerId,
          sellerType: widget.sellerType,
          wilayaId: selectedWilayaId,
          groupId: _groupId,
        );
      }
    } else {
      shippingController.resetNoestSelection(_groupId);
      _communeController.clear();
    }
  }

  int? _findNoestMethodIndex(List<ShippingMethodModel> methodList, String deliveryType) {
    for (int i = 0; i < methodList.length; i++) {
      final ShippingMethodModel method = methodList[i];
      if ((method.isNoest ?? 0) == 1 && method.deliveryType == deliveryType) {
        return i;
      }
    }
    return null;
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor.withValues(alpha: .25),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.paddingSizeDefault),
          ),
        ),
        child: SingleChildScrollView(
          child: Consumer<ShippingController>(
            builder: (context, shippingController, child) {
              final bool hasShippingList = shippingController.shippingList != null &&
                  shippingController.shippingList!.isNotEmpty &&
                  widget.sellerIndex < shippingController.shippingList!.length &&
                  shippingController.shippingList![widget.sellerIndex].shippingMethodList != null;

              final List<ShippingMethodModel> methodList = hasShippingList
                  ? (shippingController.shippingList![widget.sellerIndex].shippingMethodList ?? [])
                  : [];

              final int effectiveSelectedIndex = methodList.isEmpty
                  ? 0
                  : ((selectedIndex >= 0 && selectedIndex < methodList.length) ? selectedIndex : 0);

              if (hasShippingList && methodList.isNotEmpty && !_didBootstrap) {
                _didBootstrap = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (mounted) {
                    await _prepareInitialSelection(
                      shippingController,
                      methodList,
                      effectiveSelectedIndex,
                    );
                  }
                });
              }

              final ShippingMethodModel? selectedMethod =
                  methodList.isNotEmpty ? methodList[effectiveSelectedIndex] : null;

              final bool isNoestSelected = (selectedMethod?.isNoest ?? 0) == 1;
              final ChosenShippingMethodModel? chosenShipping =
                  shippingController.getChosenShippingByGroupId(_groupId);

              final String deliveryType = shippingController.getSelectedDeliveryType(
                _groupId,
                fallback: selectedMethod?.deliveryType ?? 'home_delivery',
              );

              final int? selectedWilayaId = shippingController.getSelectedWilayaId(_groupId);
              final String? selectedStationCode = shippingController.getSelectedStationCode(_groupId);

              final List<NoestWilayaModel> wilayas =
                  shippingController.getNoestWilayasByGroupId(_groupId);

              final List<NoestStationModel> stations =
                  shippingController.getNoestStationsByGroupId(_groupId);

              final double currentPrice = shippingController.getPendingShippingCost(
                _groupId,
                fallback: chosenShipping?.shippingCost ?? selectedMethod?.cost ?? 0,
              );

              final String estimatedDays =
                  shippingController.getEstimatedDays(_groupId) ??
                      selectedMethod?.estimatedDays ??
                      selectedMethod?.duration ??
                      '';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    getTranslated('select_shipping_method', context) ?? '',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeLarge,
                    ),
                    child: Text(
                      getTranslated('choose_a_method_for_your_delivery', context) ?? '',
                      style: textRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: shippingController.isLoading && methodList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : !hasShippingList || methodList.isEmpty
                            ? Center(
                                child: Text(
                                  getTranslated('no_shipping_method_available', context) ?? '',
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: methodList.length,
                                    itemBuilder: (context, index) {
                                      final ShippingMethodModel method = methodList[index];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: Dimensions.paddingSizeSmall,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.paddingSizeSmall,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: .25),
                                              width: .5,
                                            ),
                                            color: effectiveSelectedIndex == index
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: .1)
                                                : Theme.of(context).cardColor,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              await _onMethodSelected(
                                                shippingController,
                                                methodList,
                                                index,
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  effectiveSelectedIndex == index
                                                      ? const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                        )
                                                      : Icon(
                                                          Icons.circle_outlined,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .tertiaryContainer,
                                                        ),
                                                  const SizedBox(
                                                    width: Dimensions.paddingSizeSmall,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '${shippingController.getShippingMethodName(method)}'
                                                      '${shippingController.getShippingMethodDuration(method).isNotEmpty ? ' (${shippingController.getShippingMethodDuration(method)})' : ''}',
                                                      style: textRegular.copyWith(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions.paddingSizeSmall,
                                                  ),
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                      context,
                                                      method.cost ?? 0,
                                                    ),
                                                    style: textBold.copyWith(
                                                      fontSize: Dimensions.fontSizeLarge,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  if (isNoestSelected) ...[
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor.withValues(alpha: .20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'NOEST',
                                            style: textBold.copyWith(
                                              fontSize: Dimensions.fontSizeLarge,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.paddingSizeDefault),

                                          Text(
                                            'Delivery Type',
                                            style: textMedium.copyWith(
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.paddingSizeSmall),

                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              ChoiceChip(
                                                label: const Text('Home Delivery'),
                                                selected: deliveryType == 'home_delivery',
                                                onSelected: (bool selected) async {
                                                  if (!selected) return;

                                                  shippingController.setSelectedDeliveryType(
                                                    _groupId,
                                                    'home_delivery',
                                                  );

                                                  final int? noestHomeIndex =
                                                      _findNoestMethodIndex(methodList, 'home_delivery');

                                                  if (noestHomeIndex != null) {
                                                    setState(() {
                                                      selectedIndex = noestHomeIndex;
                                                    });
                                                    shippingController.setSelectedShippingMethod(
                                                      noestHomeIndex,
                                                      widget.sellerIndex,
                                                    );
                                                  }

                                                  if (selectedWilayaId != null) {
                                                    await shippingController.calculateNoestPrice(
                                                      context: context,
                                                      sellerId: widget.sellerId,
                                                      sellerType: widget.sellerType,
                                                      groupId: _groupId,
                                                    );
                                                  }
                                                },
                                              ),
                                              ChoiceChip(
                                                label: const Text('Desk / Office Delivery'),
                                                selected: deliveryType == 'desk_delivery',
                                                onSelected: (bool selected) async {
                                                  if (!selected) return;

                                                  shippingController.setSelectedDeliveryType(
                                                    _groupId,
                                                    'desk_delivery',
                                                  );

                                                  final int? noestDeskIndex =
                                                      _findNoestMethodIndex(methodList, 'desk_delivery');

                                                  if (noestDeskIndex != null) {
                                                    setState(() {
                                                      selectedIndex = noestDeskIndex;
                                                    });
                                                    shippingController.setSelectedShippingMethod(
                                                      noestDeskIndex,
                                                      widget.sellerIndex,
                                                    );
                                                  }

                                                  if (selectedWilayaId != null) {
                                                    await shippingController.loadNoestStations(
                                                      context: context,
                                                      sellerId: widget.sellerId,
                                                      sellerType: widget.sellerType,
                                                      wilayaId: selectedWilayaId,
                                                      groupId: _groupId,
                                                    );

                                                    await shippingController.calculateNoestPrice(
                                                      context: context,
                                                      sellerId: widget.sellerId,
                                                      sellerType: widget.sellerType,
                                                      groupId: _groupId,
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: Dimensions.paddingSizeDefault),

                                          DropdownButtonFormField<int>(
  value: selectedWilayaId,
  isExpanded: true,
  decoration: _inputDecoration(context, 'Wilaya'),
  items: wilayas.map((NoestWilayaModel wilaya) {
    return DropdownMenuItem<int>(
      value: wilaya.id,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          wilaya.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }).toList(),
  selectedItemBuilder: (BuildContext context) {
    return wilayas.map((NoestWilayaModel wilaya) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          wilaya.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    }).toList();
  },
  onChanged: (int? value) async {
    if (value == null) return;

    NoestWilayaModel? selectedWilaya;
    for (final NoestWilayaModel item in wilayas) {
      if (item.id == value) {
        selectedWilaya = item;
        break;
      }
    }

    shippingController.setSelectedWilaya(
      _groupId,
      value,
      selectedWilaya?.name,
    );

    if (deliveryType == 'desk_delivery') {
      await shippingController.loadNoestStations(
        context: context,
        sellerId: widget.sellerId,
        sellerType: widget.sellerType,
        wilayaId: value,
        groupId: _groupId,
      );
    }

    await shippingController.calculateNoestPrice(
      context: context,
      sellerId: widget.sellerId,
      sellerType: widget.sellerType,
      groupId: _groupId,
    );
  },
),

                                          const SizedBox(height: Dimensions.paddingSizeDefault),

                                          if (deliveryType == 'home_delivery') ...[
                                            TextFormField(
                                              controller: _communeController,
                                              decoration: _inputDecoration(context, 'Commune / Baladiya'),
                                              onChanged: (String value) {
                                                shippingController.setSelectedBaladiyaName(_groupId, value);
                                              },
                                            ),
                                          ],

                                          if (deliveryType == 'desk_delivery') ...[
                                            DropdownButtonFormField<String>(
  value: selectedStationCode,
  isExpanded: true,
  decoration: _inputDecoration(context, 'Station'),
  items: stations.map((NoestStationModel station) {
    final String label = station.address != null && station.address!.isNotEmpty
        ? '${station.name ?? ''} - ${station.address ?? ''}'
        : (station.name ?? '');

    return DropdownMenuItem<String>(
      value: station.code,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }).toList(),
  selectedItemBuilder: (BuildContext context) {
    return stations.map((NoestStationModel station) {
      final String label = station.address != null && station.address!.isNotEmpty
          ? '${station.name ?? ''} - ${station.address ?? ''}'
          : (station.name ?? '');

      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    }).toList();
  },
  onChanged: (String? value) async {
    if (value == null) return;

    NoestStationModel? selectedStation;
    for (final NoestStationModel item in stations) {
      if (item.code == value) {
        selectedStation = item;
        break;
      }
    }

    shippingController.setSelectedStation(
      _groupId,
      selectedStation?.code,
      selectedStation?.name,
    );

    await shippingController.calculateNoestPrice(
      context: context,
      sellerId: widget.sellerId,
      sellerType: widget.sellerType,
      groupId: _groupId,
    );
  },
)
                                          ],

                                          const SizedBox(height: Dimensions.paddingSizeDefault),

                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                              color: Theme.of(context).primaryColor.withValues(alpha: .08),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Shipping Price',
                                                  style: textMedium.copyWith(
                                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                                  ),
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                Text(
                                                  PriceConverter.convertPrice(context, currentPrice),
                                                  style: textBold.copyWith(
                                                    fontSize: Dimensions.fontSizeLarge,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                                if (estimatedDays.isNotEmpty) ...[
                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                  Text(
                                                    estimatedDays,
                                                    style: textRegular.copyWith(
                                                      color: Theme.of(context).hintColor,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: Dimensions.paddingSizeDefault),

                                  CustomButton(
                                    buttonText: getTranslated('select', context) ?? '',
                                    onTap: () async {
                                      if (methodList.isEmpty) {
                                        return;
                                      }

                                      final ShippingMethodModel method = methodList[effectiveSelectedIndex];

                                      shippingController.setSelectedShippingMethod(
                                        effectiveSelectedIndex,
                                        widget.sellerIndex,
                                      );

                                      if ((method.isNoest ?? 0) == 1) {
                                        final String currentDeliveryType =
                                            shippingController.getSelectedDeliveryType(
                                          _groupId,
                                          fallback: method.deliveryType ?? 'home_delivery',
                                        );

                                        final int? wilayaId =
                                            shippingController.getSelectedWilayaId(_groupId);

                                        shippingController.setSelectedBaladiyaName(
                                          _groupId,
                                          _communeController.text.trim(),
                                        );

                                        if (wilayaId == null) {
                                          showCustomSnackBar(
                                            'Please select wilaya',
                                            context,
                                            isToaster: true,
                                          );
                                          return;
                                        }

                                        if (currentDeliveryType == 'home_delivery' &&
                                            _communeController.text.trim().isEmpty) {
                                          showCustomSnackBar(
                                            'Please enter commune / baladiya',
                                            context,
                                            isToaster: true,
                                          );
                                          return;
                                        }

                                        if (currentDeliveryType == 'desk_delivery' &&
                                            (shippingController.getSelectedStationCode(_groupId)?.isEmpty ?? true)) {
                                          showCustomSnackBar(
                                            'Please select station',
                                            context,
                                            isToaster: true,
                                          );
                                          return;
                                        }

                                        if (shippingController.getPendingShippingCost(_groupId) <= 0) {
                                          await shippingController.calculateNoestPrice(
                                            context: context,
                                            sellerId: widget.sellerId,
                                            sellerType: widget.sellerType,
                                            groupId: _groupId,
                                          );
                                        }
                                      }

                                      await shippingController.addShippingMethod(
                                        context: context,
                                        method: method,
                                        groupId: _groupId,
                                        sellerId: widget.sellerId,
                                        sellerType: widget.sellerType,
                                      );
                                    },
                                  ),
                                ],
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}