import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/secure/secure_storage.dart';
import '../helpers/biometric/biometric_helper.dart';

enum ToggleType {
  biometric,
  mobileData,
  darkMode,
}

class GenericToggle extends StatefulWidget {
  final ToggleType type;
  final bool initialValue;
  final Function(bool) onChanged;

  const GenericToggle({
    super.key,
    required this.type,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  GenericToggleState createState() => GenericToggleState();
}

class GenericToggleState extends State<GenericToggle> {
  late bool _isOn = widget.initialValue;
  bool _isLoading = false;
  final secureStorageService = SecureStorageService();
  final biometricHelper = BiometricHelper();

  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final storedValue = await secureStorageService.readMap('currentUser');
    String? key;

    switch (widget.type) {
      case ToggleType.biometric:
        key = 'biometric';
        break;
      case ToggleType.mobileData:
        key = 'mobileData';
        break;
      case ToggleType.darkMode:
        // El modo oscuro no necesita cargarse desde SecureStorage
        return;
    }

    if (storedValue?[key] == 'on') {
      setState(() {
        _isOn = true;
      });
    } else {
      setState(() {
        _isOn = false;
      });
    }
  }

  Future<void> _updateState(bool isOn) async {
    final currentUser = await secureStorageService.readMap('currentUser');
    final owner = await secureStorageService.readMap('owner');

    if (currentUser != null && owner != null) {
      String? key;

      switch (widget.type) {
        case ToggleType.biometric:
          key = 'biometric';
          Provider.of<AppState>(context, listen: false).setUseBiometrics(isOn);
          break;
        case ToggleType.mobileData:
          key = 'mobileData';
          Provider.of<AppState>(context, listen: false).setUseMobileData(isOn);
          break;
        case ToggleType.darkMode:
          Provider.of<AppState>(context, listen: false).toggleDarkMode();
          return; // No necesita guardar en SecureStorage
      }

      currentUser[key] = isOn ? 'on' : 'off';
      owner[key] = isOn ? 'on' : 'off';
      await secureStorageService.writeMap('currentUser', currentUser);
      await secureStorageService.writeMap('owner', owner);
    }
  }

  void _toggle() async {
    setState(() {
      _isLoading = true;
    });

    bool shouldToggle = true;

    if (widget.type == ToggleType.biometric) {
      // Usar el contexto de la actividad principal, no del modal
      final BuildContext mainContext = context;
      shouldToggle =
          await biometricHelper.authenticateWithBiometrics(mainContext);
    } else if (widget.type == ToggleType.mobileData) {
      shouldToggle = await _showDataConnectionModal();
    }

    if (shouldToggle) {
      setState(() {
        _isOn = !_isOn;
      });

      widget.onChanged(_isOn);
      await _updateState(_isOn);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _showDataConnectionModal() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _isOn
                            ? 'Desactivar uso con datos móviles'
                            : 'Activar uso con datos móviles',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.smartphone,
                        color: Color(0xFF79a341),
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _isOn
                            ? 'Estás desactivando el uso con datos móviles. ¿Deseas continuar?'
                            : 'Estás activando el uso con datos móviles. Esto puede revertirse. ¿Deseas continuar?',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xFF79a341),
                            shape: RoundedRectangleBorder(),
                          ),
                          child: Text(
                            'Sí',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _toggle,
      child: Container(
        width: 60.0,
        height: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: _isOn ? const Color(0xFF79a341) : Colors.grey,
        ),
        padding: const EdgeInsets.all(4.0),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                ),
              )
            : Align(
                alignment: _isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
      ),
    );
  }
}
