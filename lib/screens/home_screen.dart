import 'package:autogl/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

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
          title: const Text("Añadir Nueva Orden"),
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
              child: const Text("Cancelar"),
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
    if (photo != null) {
      // Aquí puedes manejar la foto (subirla, guardarla, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto adjuntada correctamente")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Órdenes de Compra"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog, // Función que muestra el diálogo
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
                // Lógica de filtrado (puedes implementarla aquí)
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
