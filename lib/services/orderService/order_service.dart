import 'dart:convert';
import 'package:autogl/services/logs/log.servic.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class OrderService {
  final String? baseUrl = dotenv.env['BASE_URL_ORDERS'];

  Future<List<Map<String, dynamic>>> fetchOrders(String token) async {
    final url = Uri.parse('$baseUrl/app/ordenCompra/getLstOrdenCompra');

    LogService.log("la url a orders es: $url", level: Level.info);

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extraer la lista de órdenes de compra
      if (data.containsKey('lstOrdenCompra')) {
        return List<Map<String, dynamic>>.from(data['lstOrdenCompra']);
      }
      return [];
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
