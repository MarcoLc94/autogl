import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LogService {
  static final Logger _logger = Logger();

  // Carpeta donde se guardarán los logs
  static Future<String> _getLogFilePath() async {
    try {
      final directory =
          await getApplicationDocumentsDirectory(); // Obtener el directorio de la app
      final logDirectory = Directory('${directory.path}/logs');

      // Crear la carpeta si no existe
      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      return '${logDirectory.path}/app_logs.txt';
    } catch (e) {
      _logger.e("Error obteniendo el path del archivo de log: $e");
      rethrow;
    }
  }

  // Registrar logs
  static Future<void> log(String message, {Level level = Level.info}) async {
    try {
      final logFilePath = await _getLogFilePath();

      // Log en consola
      switch (level) {
        case Level.debug:
          _logger.d(message);
          break;
        case Level.warning:
          _logger.w(message);
          break;
        case Level.error:
          _logger.e(message);
          break;
        default:
          _logger.i(message);
      }

      // Guardar en archivo
      final logFile = File(logFilePath);
      final logEntry =
          '[${DateTime.now().toIso8601String()}] [$level] $message\n'; // Formato del log
      await logFile.writeAsString(logEntry, mode: FileMode.append, flush: true);
    } catch (e) {
      _logger.e("Error guardando el log en el archivo: $e");
    }
  }

  // Leer los logs
  static Future<String> readLogs() async {
    try {
      final logFilePath = await _getLogFilePath();
      final logFile = File(logFilePath);

      if (!await logFile.exists()) return 'No logs found.';

      return await logFile.readAsString();
    } catch (e) {
      _logger.e("Error leyendo el archivo de logs: $e");
      return 'Error reading logs';
    }
  }

  // Limpiar los logs
  static Future<void> clearLogs() async {
    try {
      final logFilePath = await _getLogFilePath();
      final logFile = File(logFilePath);

      if (await logFile.exists()) {
        await logFile.writeAsString(''); // Vaciar el archivo
      }
    } catch (e) {
      _logger.e("Error limpiando el archivo de logs: $e");
    }
  }
}
