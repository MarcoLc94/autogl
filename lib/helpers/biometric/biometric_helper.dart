import '../../screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/secure/secure_storage.dart';
import '../toast/toast_helper.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();
  final loginScreen = LoginScreenState();
  //Instancia para manejar los toast
  final toastsHelper = ToastsHelper();

  // Verifica si la biometría está disponible en el dispositivo
  Future<void> checkBiometricAvailability(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    if (canAuthenticateWithBiometrics) {
      // Verifica si tiene biometría configurada
      List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty) {
        appState.setUseBiometrics(false);
      }
    }
  }

  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    try {
      // Verifica si el dispositivo soporta biometría
      bool canAuthenticate = await _auth.canCheckBiometrics;
      if (!canAuthenticate) {
        toastsHelper.customToast("Biometría no disponible", ColorType.red);
        return false;
      }

      // Verifica si el usuario tiene biometría configurada
      List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        toastsHelper.customToast("No hay biometría configurada", ColorType.red);
        return false;
      }

      // Realiza la autenticación biométrica
      bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Por favor autentíquese para continuar',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        toastsHelper.customToast("Autenticación exitosa", ColorType.green);
        return true;
      } else {
        toastsHelper.customToast("Autenticación fallida", ColorType.red);
        return false;
      }
    } catch (e) {
      toastsHelper.customToast("Error en la autenticación: $e", ColorType.red);
      return false;
    }
  }

  Future<void> saveBiometricResponse(String biometricResponse) async {
    final prefs = await SharedPreferences.getInstance();

    // Guarda la respuesta en SharedPreferences bajo la clave 'biometricDefault'
    await prefs.setString('biometricDefault', biometricResponse);
  }

  Future<void> showBiometricDialog(BuildContext context) async {
    // Verificación de "mounted" en el helper antes de mostrar el diálogo
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            "¿Te gustaría activar el inicio de sesión con tu huella digital?",
            style: TextStyle(
              fontSize: 20, // Aumentar el tamaño del texto
              fontWeight: FontWeight.bold, // Texto más destacado
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Sí"),
              onPressed: () {
                saveBiometricResponse("on");
                Navigator.of(context).pop(); // Cerrar el modal
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCredentialsFromBiometric(
    String username,
    String password,
  ) async {
    try {
      final SecureStorageService storageService = SecureStorageService();
      // Guarda el 'username' y 'password' en SecureStorage
      await storageService.write('username', username);
      await storageService.write('password', password);
    } catch (e) {
      // Maneja cualquier error que ocurra al guardar los valores
      toastsHelper.customToast(
          "Error al guardar las credenciales", ColorType.red);
    }
  }

  //Metodo para mostrar toast
  messageBiometric() {
    toastsHelper.customToast(
        "Ingresa tus credenciales por favor.", ColorType.red);
  }
}
