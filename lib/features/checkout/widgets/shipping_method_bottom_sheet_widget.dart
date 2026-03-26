import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/noest_shipping_form_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ShippingMethodBottomSheetWidget extends StatelessWidget {
  final int sellerIndex;
  final int sellerId;
  final String sellerType;
  final String groupId;

  const ShippingMethodBottomSheetWidget({
    super.key,
    required this.sellerIndex,
    required this.sellerId,
    required this.sellerType,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ShippingController>(
      builder: (context, shippingController, _) {
        final List<ShippingMethodModel> methodList =
            shippingController.shippingList?[sellerIndex].shippingMethodList ?? [];

        final int selectedIndex =
            shippingController.shippingList?[sellerIndex].shippingIndex ?? -1;

        final ShippingMethodModel? selectedMethod =
            (selectedIndex >= 0 && selectedIndex < methodList.length)
                ? methodList[selectedIndex]
                : null;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.80,
            minHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                child: Center(
                  child: Container(
                    width: 35,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                      color: Theme.of(context).hintColor.withValues(alpha: .5),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getTranslated('shipping_method', context) ?? 'Shipping Method',
                  style: titilliumSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              Expanded(
                child: methodList.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد طرق شحن متاحة حالياً',
                          style: textRegular.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: methodList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          final ShippingMethodModel method = methodList[index];
                          final bool isSelected = selectedIndex == index;

                          final String methodName =
                              method.companyName ?? method.providerName ?? method.title ?? '';

                          final String methodDuration =
                              method.deliveryTypeLabel ?? method.estimatedDays ?? method.duration ?? '';

                          return InkWell(
                            onTap: () async {
                              shippingController.setSelectedShippingMethod(index, sellerIndex);

                              if ((method.isNoest ?? 0) == 1) {
                                await shippingController.loadNoestWilayas(
                                  context: context,
                                  sellerId: sellerId,
                                  sellerType: sellerType,
                                  groupId: groupId,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withValues(alpha: .08)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor.withValues(alpha: .25),
                                  width: isSelected ? 1.1 : .5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  if ((method.logo?.isNotEmpty ?? false))
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        method.logo!,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha: .08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.local_shipping_outlined),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: .08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.local_shipping_outlined),
                                    ),

                                  const SizedBox(width: Dimensions.paddingSizeDefault),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          methodName,
                                          style: textMedium.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                        Text(
                                          PriceConverter.convertPrice(context, method.cost ?? 0),
                                          style: textRegular.copyWith(
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        if (methodDuration.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            methodDuration,
                                            style: textRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).hintColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              if ((selectedMethod?.isNoest ?? 0) == 1)
                NoestShippingFormWidget(
                  sellerId: sellerId,
                  sellerType: sellerType,
                  groupId: groupId,
                ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomButton(
                buttonText: getTranslated('save', context) ?? 'Save',
                onTap: selectedMethod == null ? null : () async {
                  await shippingController.addShippingMethod(
                    context: context,
                    method: selectedMethod,
                    groupId: groupId,
                    sellerId: sellerId,
                    sellerType: sellerType,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}