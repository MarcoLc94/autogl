import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _emailTouched = false;
  bool _isLoading = false;

  bool _isEmailValid() {
    return _emailController.text.isNotEmpty &&
        _emailController.text.contains('@');
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    // Simulamos un retraso de red
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Se ha enviado un enlace de recuperación a ${_emailController.text}'),
        backgroundColor: Colors.green,
      ),
    );

    // Regresar al login después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final appState = Provider.of<AppState>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fondo con gradiente (igual que tu login)
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.2),
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      "assets/images/Resetpassword3.gif",
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenedor del formulario
          Positioned(
            top: 280,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: 5,
                            child: Container(
                              height: 12,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Text(
                            "Recuperar Contraseña",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subtítulo
                    Text(
                      'Ingresa tu correo electrónico para recibir instrucciones de recuperación',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() => _emailTouched = true),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                        prefixIcon: Icon(
                          Icons.email,
                          size: 22,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 2.0,
                          ),
                        ),
                        errorText: _emailTouched && !_isEmailValid()
                            ? 'Ingresa un correo válido'
                            : null,
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 40),

                    // Botón de enviar
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _isEmailValid() && !_isLoading ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEmailValid()
                              ? Theme.of(context).colorScheme.onSecondary
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: _isEmailValid() ? 5 : 0,
                          shadowColor: _isEmailValid()
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : Text(
                                "Enviar enlace",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isEmailValid()
                                      ? Theme.of(context).colorScheme.surface
                                      : Colors.grey.withValues(alpha: 0.5),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón para volver al login
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
