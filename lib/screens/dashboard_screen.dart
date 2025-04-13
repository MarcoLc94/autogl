import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userSesion') ??
        'usuario'; // Valor por defecto si no existe
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalComprasMes = 8;
    final sinFoto = 2;
    final sinSync = 1;

    final comprasRecientes = [
      {"titulo": "Compra de motor completo", "fecha": "2025-04-10"},
      {"titulo": "Compra de faros delanteros", "fecha": "2025-04-09"},
      {"titulo": "Compra de kit de frenos", "fecha": "2025-04-08"},
      {"titulo": "Compra de llantas 18\"", "fecha": "2025-04-07"},
      {"titulo": "Compra de batería 12V", "fecha": "2025-04-06"},
      {"titulo": "Compra de amortiguadores", "fecha": "2025-04-05"},
      {"titulo": "Compra de filtros de aire", "fecha": "2025-04-04"},
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
            FutureBuilder<String>(
              future: _getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('@cargando...'); // Mientras carga
                }
                return Text(
                  "¡Hola, ${snapshot.data}!",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.secondaryContainer,
                  ),
                );
              },
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
                  color: colorScheme.secondaryContainer,
                ),
                _ResumenCard(
                  icon: Icons.photo,
                  label: "Sin foto",
                  value: "$sinFoto",
                  color: colorScheme.secondaryContainer,
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
                  color: colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            Container(
              height: MediaQuery.of(context).size.height *
                  0.22, // 35% del alto de pantalla
              decoration: BoxDecoration(
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: comprasRecientes.length,
                  itemBuilder: (context, index) {
                    final compra = comprasRecientes[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(Icons.receipt_long,
                          color: colorScheme.secondaryContainer),
                      title: Text(
                        compra["titulo"]!,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      subtitle: Text(
                        "Fecha: ${compra["fecha"]}",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text("Accesos rápidos",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                _QuickActionButton(
                  icon: Icons.add,
                  label: "Nueva compra",
                  color: colorScheme.secondaryContainer,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.photo_library,
                  label: "Galería",
                  color: colorScheme.secondaryContainer,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.search,
                  label: "Buscar",
                  color: colorScheme.secondaryContainer,
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
                    color: colorScheme.onSurfaceVariant,
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
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
