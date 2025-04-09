import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  bool _useBiometrics = false;
  bool _isFirstLaunch =
      true; // Flag para saber si es el primer lanzamiento de la app
  bool _useMobileData = false;
  bool _isDarkMode = false;

  AppState() {
    _loadBiometricPreference();
    _loadMobileDataPreference();
    _loadDarkModePreference(); // Agregar carga del modo oscuro si es necesario
  }

  bool get isDarkMode => _isDarkMode;
  bool get useBiometrics => _useBiometrics;
  bool get useMobileData => _useMobileData;
  bool get isFirstLaunch => _isFirstLaunch;

  void setUseBiometrics(bool value) async {
    _useBiometrics = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('biometricDefault', value ? 'on' : 'off');
    notifyListeners();
  }

  void setUseMobileData(bool value) async {
    _useMobileData = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileData', value ? 'on' : 'off');
    notifyListeners();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void _loadDarkModePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDarkModeOn =
        prefs.getBool('isDarkMode') ?? false; // Valor predeterminado: false
    _isDarkMode = isDarkModeOn;
    notifyListeners();
  }

  void _loadBiometricPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isBiometricOn = prefs.getString('biometricDefault') == 'on';
    setUseBiometrics(isBiometricOn);
  }

  void _loadMobileDataPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isMobileDataOn = prefs.getString('mobileData') == 'on';
    setUseMobileData(isMobileDataOn);
  }

  void setIsFirstLaunch(bool value) {
    _isFirstLaunch = value;
    notifyListeners();
  }
}
