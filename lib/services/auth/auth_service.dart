import 'package:autogl/services/logs/log.servic.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthService {
  final String? baseUrl;
  final Dio _dio = Dio();
  final _storage = SharedPreferences.getInstance();

  // Constructor que recibe la baseUrl
  AuthService({required this.baseUrl}) {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              // Reintentar la petición original con el nuevo token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            await logout();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<String?> _refreshToken() async {
    final prefs = await _storage;
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '$baseUrl/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'];
      await prefs.setString('auth_token', newAccessToken);
      return newAccessToken;
    } catch (e) {
      await logout();
      return null;
    }
  }

  // Método para hacer login
  Future<String> login(String user, String password) async {
    LogService.log("intentando con credenciales: $user y $password",
        level: Level.info);
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
        String userSesion = user;
        String refreshToken = await getRefreshToken(token);

        // print("el token es: $token");
        saveTokens(token, refreshToken, userSesion);
        saveUserSesion(userSesion);

        return token; // Login exitoso
      } else {
        LogService.log("Este es el log de andres: ${response.body}",
            level: Level.fatal);
        return "Error"; // Login fallido
      }
    } catch (e) {
      return "Error";
    }

    //SOlo usar estas lineas para desactivar el AUTH
    // final prefs = await _storage;
    // await prefs.setString('userSesion', user);
    // return "123";
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

  Future<void> saveTokens(
      String accessToken, String refreshToken, String user) async {
    final prefs = await _storage;
    await prefs.setString('auth_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('userSesion', user);
  }

//PARA INFO COMPLETA
  Future<void> saveUser(Map<String, dynamic> userInfo) async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    // Convertir el userInfo a un String (JSON)
    String jsonString = json.encode(userInfo);
    // Guardarlo en SharedPreferences
    await userData.setString('userInfo', jsonString);
  }

//PARA SOLO SU USERNAME
  Future<void> saveUserSesion(String userInfo) async {
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

  Future<String> getRefreshToken(String token) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/app/token/refresh'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          body: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String refreshtoken = data;
        return refreshtoken;
      } else {
        LogService.log("Este es el log de andres: ${response.body}",
            level: Level.fatal);
        return "Error"; // Login fallido
      }
    } catch (e) {
      return "Error";
    }
  }
}
