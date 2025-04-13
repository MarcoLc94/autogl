import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrderService {
  final baseUrl = dotenv.env['BASE_URL'];
  late var orders = [];
}
