import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/white.jpg'),
          fit: BoxFit.cover,
          opacity: 0.95,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/logo-bg-dark.png'
                        : 'assets/logo-bg.png',
                  ),
                  width: 250,
                ),
                Text(
                  "Bienvenido",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 35,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 20),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 70),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary, // Cambia el color de fondo
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // Cambia el color del borde
                      width: 5.0, // Cambia el grosor del borde
                    ),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forget_password');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 70),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 5.0),
                  ),
                  child: Text(
                    'Olvide mi contraseña',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
