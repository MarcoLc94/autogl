// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../helpers/biometric/biometric_helper.dart';

enum ToggleType {
  biometric,
  mobileData,
  darkMode,
}

class GenericToggle extends StatefulWidget {
  final ToggleType type;
  final Function(bool)? onChanged;

  const GenericToggle({
    super.key,
    required this.type,
    this.onChanged,
  });

  @override
  GenericToggleState createState() => GenericToggleState();
}

class GenericToggleState extends State<GenericToggle> {
  bool _isLoading = false;
  final biometricHelper = BiometricHelper();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    bool currentValue;

    switch (widget.type) {
      case ToggleType.biometric:
        currentValue = appState.useBiometrics;
        break;
      case ToggleType.mobileData:
        currentValue = appState.useMobileData;
        break;
      case ToggleType.darkMode:
        currentValue = appState.isDarkMode;
        break;
    }

    return GestureDetector(
      onTap: _isLoading ? null : () => _toggle(context, appState, currentValue),
      child: Container(
        width: 60.0,
        height: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: currentValue
              ? Theme.of(context).colorScheme.secondaryContainer
              : Colors.grey,
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
                alignment:
                    currentValue ? Alignment.centerRight : Alignment.centerLeft,
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

  Future<void> _toggle(
      BuildContext context, AppState appState, bool currentValue) async {
    setState(() => _isLoading = true);

    bool shouldToggle = true;

    if (widget.type == ToggleType.biometric) {
      shouldToggle = await biometricHelper.authenticateWithBiometrics(context);
    } else if (widget.type == ToggleType.mobileData) {
      shouldToggle = await _showDataConnectionModal(context, currentValue);
    }

    if (shouldToggle) {
      switch (widget.type) {
        case ToggleType.biometric:
          appState.setUseBiometrics(!currentValue);
          break;
        case ToggleType.mobileData:
          appState.setUseMobileData(!currentValue);
          break;
        case ToggleType.darkMode:
          appState.toggleDarkMode();
          break;
      }
      widget.onChanged?.call(!currentValue);
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _showDataConnectionModal(
      BuildContext context, bool isCurrentlyOn) async {
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
                        isCurrentlyOn
                            ? 'Desactivar uso con datos móviles'
                            : 'Activar uso con datos móviles',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.smartphone,
                        color: const Color(0xFF79a341),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        isCurrentlyOn
                            ? 'Estás desactivando el uso con datos móviles. ¿Deseas continuar?'
                            : 'Estás activando el uso con datos móviles. Esto puede revertirse. ¿Deseas continuar?',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF79a341),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0)),
                          ),
                          child: const Text(
                            'Sí',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0)),
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
}
