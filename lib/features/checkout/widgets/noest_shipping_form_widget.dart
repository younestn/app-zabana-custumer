import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_station_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/noest_wilaya_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:provider/provider.dart';

class NoestShippingFormWidget extends StatelessWidget {
  final int sellerId;
  final String sellerType;
  final String groupId;

  const NoestShippingFormWidget({
    super.key,
    required this.sellerId,
    required this.sellerType,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ShippingController>(
      builder: (context, shippingController, _) {
        final List<NoestWilayaModel> wilayas = shippingController.noestWilayaMap[groupId] ?? [];
        final List<NoestStationModel> stations = shippingController.noestStationMap[groupId] ?? [];
        final double shippingCost = shippingController.pendingShippingCostMap[groupId] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: null,
              hint: const Text('نوع التوصيل'),
              items: const [
                DropdownMenuItem(value: 'home_delivery', child: Text('Home Delivery')),
                DropdownMenuItem(value: 'desk_delivery', child: Text('Desk Delivery')),
              ],
              onChanged: (value) {
                if (value != null) {
                  shippingController.setSelectedDeliveryType(groupId, value);
                }
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: null,
              hint: const Text('اختر الولاية'),
              items: wilayas.map((w) {
                return DropdownMenuItem<int>(
                  value: w.id,
                  child: Text(w.name ?? ''),
                );
              }).toList(),
              onChanged: (value) async {
                final selected = wilayas.firstWhere((e) => e.id == value);
                shippingController.setSelectedWilaya(groupId, value, selected.name);

                await shippingController.loadNoestStations(
                  context: context,
                  sellerId: sellerId,
                  sellerType: sellerType,
                  wilayaId: value!,
                  groupId: groupId,
                );

                await shippingController.calculateNoestPrice(
                  context: context,
                  sellerId: sellerId,
                  sellerType: sellerType,
                  groupId: groupId,
                );
              },
            ),

            const SizedBox(height: 12),

            if (stations.isNotEmpty)
              DropdownButtonFormField<String>(
                value: null,
                hint: const Text('اختر المحطة'),
                items: stations.map((station) {
                  return DropdownMenuItem<String>(
                    value: station.code,
                    child: Text(station.name ?? ''),
                  );
                }).toList(),
                onChanged: (value) async {
                  final selected = stations.firstWhere((e) => e.code == value);
                  shippingController.setSelectedStation(groupId, selected.code, selected.name);

                  await shippingController.calculateNoestPrice(
                    context: context,
                    sellerId: sellerId,
                    sellerType: sellerType,
                    groupId: groupId,
                  );
                },
              ),

            const SizedBox(height: 12),

            Text('سعر الشحن: ${PriceConverter.convertPrice(context, shippingCost)}'),
          ],
        );
      },
    );
  }
}