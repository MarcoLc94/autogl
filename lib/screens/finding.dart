import 'package:flutter/material.dart';

class FindingScreen extends StatelessWidget {
  const FindingScreen({super.key});

  // Simulación de array de piezas
  final List<String> piezas =
      const []; // Cambia esto si en algún momento tienes datos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Lista de piezas buscadas',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        centerTitle: true,
      ),
      body: piezas.isEmpty
          ? Center(
              child: Text(
                'No hay piezas para comprar en este momento',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
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
    );
  }
}
