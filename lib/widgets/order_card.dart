import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String vehicle;
  final String part;
  final String supplier;
  final String amount;
  final String currency;
  final Function()? onAttachPhoto;
  final bool isSynced;
  final DateTime? lastSyncDate;
  final bool isLocal;

  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.vehicle,
    required this.part,
    required this.supplier,
    required this.amount,
    required this.currency,
    this.onAttachPhoto,
    this.isSynced = true,
    this.lastSyncDate,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con número de pedido y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Pedido #$orderNumber",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLocal)
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.orange,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt,
                      color: colorScheme.secondaryContainer),
                  onPressed: onAttachPhoto,
                ),
              ],
            ),

            // Estado de sincronización
            if (!isSynced || isLocal)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      isSynced ? Icons.cloud_done : Icons.cloud_off,
                      size: 14,
                      color: isSynced ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isLocal ? 'Pendiente de sincronizar' : 'Modo offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLocal
                            ? Colors.orange
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // Detalles de la orden
            _buildDetailRow(context, "Vehículo:", vehicle),
            _buildDetailRow(context, "Pieza:", part),
            _buildDetailRow(context, "Proveedor:", supplier),

            const SizedBox(height: 8),

            // Monto y última sincronización
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monto: $amount $currency",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (lastSyncDate != null)
                  Text(
                    "Sincronizado: ${DateFormat('dd/MM HH:mm').format(lastSyncDate!)}",
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
