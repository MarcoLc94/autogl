import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  bool _useBiometrics = false;
  bool _isFirstLaunch = true;
  bool _useMobileData = false;
  bool _isDarkMode = false;
  bool _isLoading = false;

  AppState() {
    _loadPreferences();
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get useBiometrics => _useBiometrics;
  bool get useMobileData => _useMobileData;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLoading => _isLoading;

  // Carga inicial de preferencias
  Future<void> _loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _useBiometrics = prefs.getString('biometricDefault') == 'on';
    _useMobileData = prefs.getString('mobileData') == 'on';

    _isLoading = false;
    notifyListeners();
  }

  void setUseBiometrics(bool value) async {
    _useBiometrics = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('biometricDefault', value ? 'on' : 'off');
  }

  void setUseMobileData(bool value) async {
    _useMobileData = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileData', value ? 'on' : 'off');
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void setIsFirstLaunch(bool value) {
    _isFirstLaunch = value;
    notifyListeners();
  }
}
