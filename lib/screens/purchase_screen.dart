import 'dart:async';
import 'package:autogl/helpers/toast/toast_helper.dart';
import 'package:autogl/services/auth/auth_service.dart';
import 'package:autogl/services/logs/log.servic.dart';
import 'package:autogl/services/orderService/order_service.dart';
import 'package:autogl/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/web.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final baseUrl = dotenv.env['BASE_URL_ORDERS'];
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final toasthelper = ToastsHelper();
  final orderService = OrderService();
  late final AuthService authservice;

  @override
  void initState() {
    super.initState();
    authservice = AuthService(baseUrl: baseUrl);
    _sync();
  }

  Future<void> _sync([bool fromButton = false]) async {
    // Log informativo
    LogService.log("Sincronizando...", level: Level.info);

    // Notificación en pantalla
    if (fromButton) {
      toasthelper.customToast("Sincronizando...", ColorType.blue);
    }

    try {
      // Obtención del token (correcto)
      final token = await authservice.getToken();

      // Llamada al servicio (correcto)
      final orders = await orderService.fetchOrders(token!);

      // Actualización del estado con conversión de tipos (aquí depende de lo que necesites)
      setState(() {
        _orders.clear();
        _orders.addAll(
          orders.map(
            (o) => o.map(
                (key, value) => MapEntry(key.toString(), value.toString())),
          ),
        );
      });

      if (fromButton) {
        // Confirmación al usuario
        toasthelper.customToast("Órdenes actualizadas", ColorType.blue);
      }
    } catch (e) {
      // Manejo de errores con notificación
      toasthelper.customToast("Error: $e", ColorType.red);
    }
  }

  void _showAddOrderDialog() {
    final TextEditingController orderNumberController = TextEditingController();
    final TextEditingController vehicleController = TextEditingController();
    final TextEditingController partController = TextEditingController();
    final TextEditingController supplierController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController currencyController =
        TextEditingController(text: "USD");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Añadir Nueva Orden",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orderNumberController,
                  decoration: const InputDecoration(labelText: "No. Pedido"),
                ),
                TextField(
                  controller: vehicleController,
                  decoration: const InputDecoration(labelText: "Vehículo"),
                ),
                TextField(
                  controller: partController,
                  decoration: const InputDecoration(labelText: "Pieza"),
                ),
                TextField(
                  controller: supplierController,
                  decoration: const InputDecoration(labelText: "Proveedor"),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: "Monto"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: currencyController,
                  decoration: const InputDecoration(labelText: "Moneda"),
                ),
              ],
            ),
          ),
          actions: [
            // Botón "Registrar" (antes "Cancelar")
            TextButton.icon(
              onPressed: () {
                if (orderNumberController.text.isNotEmpty &&
                    vehicleController.text.isNotEmpty &&
                    partController.text.isNotEmpty &&
                    supplierController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    _orders.add({
                      "orderNumber": orderNumberController.text,
                      "vehicle": vehicleController.text,
                      "part": partController.text,
                      "supplier": supplierController.text,
                      "amount": amountController.text,
                      "currency": currencyController.text,
                    });
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("¡Completa todos los campos!")),
                  );
                }
              },
              icon: const Icon(Icons.edit), // ícono de lápiz
              label: const Text("Registrar"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            // Botón "Entregar" deshabilitado
            ElevatedButton.icon(
              onPressed: null, // deshabilitado por el momento
              icon: const Icon(Icons.mail_outline), // ícono de sobre de carta
              label: const Text("Entregar"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  // Datos hardcodeados (simulados)
  final List<Map<String, String>> _orders = [];

  // Función para abrir la cámara
  Future<void> _attachPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (photo != null) {
      // Aquí puedes manejar la foto (subirla, guardarla, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto adjuntada correctamente")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Icono de orden de compra en lugar de la flecha back
          icon: Icon(
            Symbols.shopping_cart,
            size: 24,
            color: Theme.of(context).colorScheme.onPrimary,
          ), // Icono de orden de compra
          onPressed: () {}, // Puedes dejarlo vacío o agregar una acción
        ),
        title: Text(
          "Órdenes de Compra",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          // Aquí colocamos el ícono de sync al final
          IconButton(
            icon: Icon(
              Symbols.sync,
              size: 30,
              color: Theme.of(context).colorScheme.secondary,
              weight: 400,
            ),
            onPressed: () => _sync(true),
          ),
        ],
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog,
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer, // Color de fondo
        foregroundColor:
            Theme.of(context).colorScheme.surface, // Color del icono
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar pedido...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                // Lógica de filtrado
              },
            ),
            const SizedBox(height: 20),
            // Lista de Cards
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return OrderCard(
                    orderNumber: order["idOrdenCompra"]!,
                    vehicle: order["vehiculo"]!,
                    part: order["refaccion"]!,
                    supplier: order["nombreProveedor"]!,
                    amount: order["monto"]!,
                    currency: order["moneda"]!,
                    onAttachPhoto: _attachPhoto,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
