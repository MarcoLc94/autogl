import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ColorType { green, blue, red, dark }

Map<ColorType, int> colors = {
  ColorType.green: 0xFF79a341,
  ColorType.blue: 0xFF194583, // Ejemplo: un color azul
  ColorType.red: 0xFFFF0000, // Ejemplo: un color rojo
  ColorType.dark: 0xFF383838,
};

class ToastsHelper {
  customToast(String message, [ColorType color = ColorType.green]) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(colors[color]!),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Función para mostrar mensajes con FlutterToast
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: message.contains("correcto")
          ? Color.fromRGBO(22, 67, 127, 1)
          : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
