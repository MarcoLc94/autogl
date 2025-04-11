import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String? baseUrl; // URL base de tu API

  ApiService({required this.baseUrl});

  // Método para obtener el token de SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('auth_token'); // Obtiene el token con la clave 'auth_token'
  }

  // Método para construir los headers con el token
  Future<Map<String, String>> _buildHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Incluye el token en el header
    };
  }

  // Método genérico para hacer una petición GET
  Future<dynamic> get(String endpoint) async {
    final headers = await _buildHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Método genérico para hacer una petición POST
  Future<dynamic> post(String endpoint, dynamic body) async {
    final headers = await _buildHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Método genérico para hacer una petición PUT
  Future<dynamic> put(String endpoint, dynamic body) async {
    final headers = await _buildHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Método genérico para hacer una petición DELETE
  Future<dynamic> delete(String endpoint) async {
    final headers = await _buildHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Maneja la respuesta de la API
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Si la respuesta es exitosa, devuelve el cuerpo decodificado
      return jsonDecode(response.body);
    } else {
      // Si la respuesta no es exitosa, lanza una excepción
      throw Exception(
          'Error: ${response.statusCode}, ${response.reasonPhrase}, ${response.body}');
    }
  }
}
