import 'dart:async';
import 'dart:convert'; // Para serializar y deserializar JSON
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Creamos una instancia simple sin opciones específicas de plataforma
  final _secureStorage = FlutterSecureStorage();

  // StreamController para emitir eventos cuando los datos cambien
  final StreamController<Map<String, String>> _onChangeController =
      StreamController.broadcast();

  // Exponer el Stream para que otros puedan escucharlo
  Stream<Map<String, String>> get onChange => _onChangeController.stream;

  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
    await _emitCurrentState();
  }

  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
    await _emitCurrentState();
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
    await _emitCurrentState();
  }

  Future<void> writeMap(String key, Map<String, String> map) async {
    try {
      final jsonString = jsonEncode(map);
      await write(key, jsonString);
    } catch (e) {
      return;
    }
  }

  Future<Map<String, String>?> readMap(String key) async {
    try {
      final jsonString = await read(key);
      if (jsonString != null) {
        return Map<String, String>.from(jsonDecode(jsonString));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Método para emitir el estado actual del almacenamiento
  Future<void> _emitCurrentState() async {
    final allKeys = await _secureStorage.readAll();
    _onChangeController.add(allKeys);
  }

  void dispose() {
    _onChangeController.close();
  }
}
