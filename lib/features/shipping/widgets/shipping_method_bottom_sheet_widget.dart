import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ShippingMethodBottomSheetWidget extends StatefulWidget {
  final String? groupId;
  final int? sellerId;
  final int sellerIndex;

  const ShippingMethodBottomSheetWidget({
    super.key,
    required this.groupId,
    required this.sellerId,
    required this.sellerIndex,
  });

  @override
  State<ShippingMethodBottomSheetWidget> createState() =>
      _ShippingMethodBottomSheetWidgetState();
}

class _ShippingMethodBottomSheetWidgetState
    extends State<ShippingMethodBottomSheetWidget> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    final shippingController =
        Provider.of<ShippingController>(context, listen: false);

    if (shippingController.shippingList != null &&
        shippingController.shippingList!.isNotEmpty &&
        widget.sellerIndex < shippingController.shippingList!.length) {
      selectedIndex =
          shippingController.shippingList![widget.sellerIndex].shippingIndex ?? 0;
    }
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
              final bool hasShippingList =
                  shippingController.shippingList != null &&
                      shippingController.shippingList!.isNotEmpty &&
                      widget.sellerIndex < shippingController.shippingList!.length &&
                      shippingController
                              .shippingList![widget.sellerIndex].shippingMethodList !=
                          null;

              final List<ShippingMethodModel> methodList = hasShippingList
                  ? (shippingController
                          .shippingList![widget.sellerIndex].shippingMethodList ??
                      [])
                  : [];

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
                    child: shippingController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : !hasShippingList
                            ? Center(
                                child: Text(
                                  getTranslated('no_shipping_method_available', context) ?? '',
                                ),
                              )
                            : methodList.isEmpty
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
                                          final ShippingMethodModel method =
                                              methodList[index];

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
                                                color: selectedIndex == index
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: .1)
                                                    : Theme.of(context).cardColor,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectedIndex = index;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      selectedIndex == index
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
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${method.title ?? ''} (Duration ${method.duration ?? ''})',
                                                          style: textRegular.copyWith(
                                                            color: Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                      Text(
                                                        PriceConverter.convertPrice(
                                                          context,
                                                          method.cost ?? 0,
                                                        ),
                                                        style: textBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
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

                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      CustomButton(
                                        buttonText:
                                            getTranslated('select', context) ?? '',
                                        onTap: () async {
                                          Provider.of<ShippingController>(
                                            context,
                                            listen: false,
                                          ).setSelectedShippingMethod(
                                            selectedIndex,
                                            widget.sellerIndex,
                                          );

                                          final selectedMethod =
                                              methodList[selectedIndex];

                                        await shippingController.addShippingMethod(
  context: context,
  method: selectedMethod,
  groupId: widget.groupId ?? '',
  sellerId: widget.sellerId,
  sellerType: 'seller',
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