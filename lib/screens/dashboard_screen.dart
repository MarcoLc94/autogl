import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userName = "Carlos";
    final totalComprasMes = 8;
    final sinFoto = 2;
    final sinSync = 1;

    final comprasRecientes = [
      {"titulo": "Compra supermercado", "fecha": "2025-04-10"},
      {"titulo": "Compra papelería", "fecha": "2025-04-09"},
      {"titulo": "Compra refacciones", "fecha": "2025-04-08"},
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Resumen"),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola, $userName!",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Aquí tienes un resumen de tu actividad reciente",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ResumenCard(
                  icon: Icons.shopping_cart,
                  label: "Este mes",
                  value: "$totalComprasMes",
                  color: colorScheme.secondary,
                ),
                _ResumenCard(
                  icon: Icons.photo,
                  label: "Sin foto",
                  value: "$sinFoto",
                  color: colorScheme.secondary,
                ),
                _ResumenCard(
                  icon: Icons.sync_problem,
                  label: "Sin sync",
                  value: "$sinSync",
                  color: colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text("Compras recientes",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                )),
            const SizedBox(height: 12),
            Column(
              children: comprasRecientes.map((compra) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.receipt_long, color: colorScheme.secondary),
                  title: Text(
                    compra["titulo"]!,
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  subtitle: Text(
                    "Fecha: ${compra["fecha"]}",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text("Accesos rápidos",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                _QuickActionButton(
                  icon: Icons.add,
                  label: "Nueva compra",
                  color: colorScheme.secondary,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.photo_library,
                  label: "Galería",
                  color: colorScheme.secondary,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.search,
                  label: "Buscar",
                  color: colorScheme.secondary,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResumenCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  )),
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 118,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onPrimary)),
          ],
        ),
      ),
    );
  }
}
