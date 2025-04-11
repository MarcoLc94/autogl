import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String vehicle;
  final String part;
  final String supplier;
  final String amount;
  final String currency;
  final Function()? onAttachPhoto;

  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.vehicle,
    required this.part,
    required this.supplier,
    required this.amount,
    required this.currency,
    this.onAttachPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "No. Pedido: $orderNumber",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: onAttachPhoto,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Vehículo: $vehicle"),
            Text("Pieza: $part"),
            Text("Proveedor: $supplier"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monto: $amount $currency",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
