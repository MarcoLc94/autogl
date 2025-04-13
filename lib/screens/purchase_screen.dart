import 'package:autogl/helpers/toast/toast_helper.dart';
import 'package:autogl/services/logs/log.servic.dart';
import 'package:autogl/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/web.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final toasthelper = ToastsHelper();

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
          title: Text(
            "Añadir Nueva Orden",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validar campos
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Datos hardcodeados (simulados)
  final List<Map<String, String>> _orders = [
    {
      "orderNumber": "ORD-1001",
      "vehicle": "Toyota Corolla",
      "part": "Filtro de aceite",
      "supplier": "Autopartes SA",
      "amount": "150.00",
      "currency": "USD",
    },
    {
      "orderNumber": "ORD-1002",
      "vehicle": "Honda Civic",
      "part": "Pastillas de freno",
      "supplier": "Repuestos Veloz",
      "amount": "85.50",
      "currency": "USD",
    },
    {
      "orderNumber": "ORD-1003",
      "vehicle": "Ford F-150",
      "part": "Batería",
      "supplier": "PowerEnergy",
      "amount": "200.00",
      "currency": "USD",
    },
    {
      "orderNumber": "ORD-1004",
      "vehicle": "Chevrolet Spark",
      "part": "Llantas",
      "supplier": "Ruedas MX",
      "amount": "320.75",
      "currency": "USD",
    },
  ];

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

  // Función para abrir la cámara
  Future<void> _sync() async {
    LogService.log("Sincronizando...", level: Level.info);
    toasthelper.customToast("SIncronizando...", ColorType.blue);
    //TODO: hacer funcion de actualizar con metodo GET ALL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Icono de orden de compra en lugar de la flecha back
          icon: Icon(
            Symbols.shopping_cart,
            size: 24,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ), // Icono de orden de compra
          onPressed: () {}, // Puedes dejarlo vacío o agregar una acción
        ),
        title: Text(
          "Órdenes de Compra",
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          // Aquí colocamos el ícono de sync al final
          IconButton(
            icon: Icon(
              Symbols.sync,
              size: 30,
              color: Theme.of(context).colorScheme.secondaryContainer,
              weight: 400,
            ),
            onPressed: _sync,
          ),
        ],
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
                    orderNumber: order["orderNumber"]!,
                    vehicle: order["vehicle"]!,
                    part: order["part"]!,
                    supplier: order["supplier"]!,
                    amount: order["amount"]!,
                    currency: order["currency"]!,
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
