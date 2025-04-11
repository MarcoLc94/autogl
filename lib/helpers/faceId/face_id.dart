import 'package:autogl/helpers/toast/toast_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class FaceIdHelper {
  final LocalAuthentication _auth = LocalAuthentication();
  final toastsHelper = ToastsHelper();
  Future<bool> authenticateWithFaceID() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Por favor, autentícate con Face ID',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        toastsHelper.customToast(
            "No hay datos de Face ID registrados en el dispositivo.",
            ColorType.red);
      } else if (e.code == auth_error.notAvailable) {
        toastsHelper.customToast(
            "Face ID no está disponible en este dispositivo.", ColorType.red);
      } else {
        toastsHelper.customToast(
            "Error desconocido: ${e.message}", ColorType.red);
      }
      return false;
    }
  }
}
