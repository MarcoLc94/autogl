import 'package:autogl/services/logs/log.servic.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthService {
  final String? baseUrl;

  // Constructor que recibe la baseUrl
  AuthService({required this.baseUrl});

  // Método para hacer login
  Future<String> login(String user, String password) async {
    print("intentando con credenciales: $user y $password");
    try {
      final response = await http.post(Uri.parse('$baseUrl/login'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          body:
              'username=${Uri.encodeComponent(user)}&password=${Uri.encodeComponent(password)}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        // saveUser(data['user']);
        // print("Los datos de user son: $data");
        print("el token es: $token");
        saveToken(token);

        return token; // Login exitoso
      } else {
        LogService.log("Este es el log de andres: ${response.body}",
            level: Level.fatal);
        return "Error"; // Login fallido
      }
    } catch (e) {
      return "Error";
    }
  }

  // Método para obtener el token desde SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Método para cerrar sesión y eliminar el token
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Guardamos el token en SharedPreferences
    await prefs.setString('auth_token', token);
  }

  Future<void> saveUser(Map<String, dynamic> userInfo) async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    // Convertir el userInfo a un String (JSON)
    String jsonString = json.encode(userInfo);
    // Guardarlo en SharedPreferences
    await userData.setString('userInfo', jsonString);
  }

  Future<bool> isTokenValid() async {
    String? token = await getToken();
    if (token == null) {
      return false; // No hay token almacenado
    }

    try {
      // Decodificar el token sin verificar la firma
      final jwt = JWT.decode(token);

      // Obtener la fecha de expiración (campo 'exp')
      final exp = jwt.payload['exp'];
      if (exp == null) {
        return false; // El token no tiene fecha de expiración
      }

      // Convertir 'exp' a DateTime y comparar
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expirationDate.isAfter(DateTime.now());
    } catch (e) {
      return false; // Token inválido
    }
  }
}
