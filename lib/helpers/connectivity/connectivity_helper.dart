import '../toast/toast_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityHelper {
  static Future<bool> checkConnectivity() async {
    final toastsHelper = ToastsHelper();
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      toastsHelper.customToast("No hay conexión a Internet", ColorType.red);
      return false;
    }
    return true;
  }

  static void handleConnectivityChange(List<ConnectivityResult> results) {
    final toastsHelper = ToastsHelper();
    if (results.contains(ConnectivityResult.none)) {
      toastsHelper.customToast("No hay conexión a Internet", ColorType.red);
    } else if (results.contains(ConnectivityResult.wifi)) {
      toastsHelper.customToast("Conectado a Wi-Fi", ColorType.blue);
    } else if (results.contains(ConnectivityResult.mobile)) {
      toastsHelper.customToast("Conectado a red móvil", ColorType.blue);
    }
  }

  void retry(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false, // Esto elimina todas las rutas anteriores
    );
  }
}
