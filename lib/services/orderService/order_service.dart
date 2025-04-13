import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/Crud/api_service.dart';

class OrderService {
  final baseUrl = dotenv.env['BASE_URL'];
  late var orders = [];

  OrderService() {}
}
