import 'package:flutter/material.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final TextEditingController _ordenController = TextEditingController();
  List<String> piezas = [];

  void _buscarPiezas() {
    setState(() {
      // Simulación: buscar piezas (por ahora siempre está vacío)
      piezas = []; // Aquí puedes agregar lógica real más adelante
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Agregar fotos',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ordenController,
              decoration: const InputDecoration(
                labelText: 'Orden de compra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: _buscarPiezas,
                child: Text('Buscar',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.surface)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lista de piezas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondaryContainer),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: piezas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay piezas en la orden de compra',
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: piezas.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(piezas[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ordenController.dispose();
    super.dispose();
  }
}
