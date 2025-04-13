import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../helpers/faceId/face_id.dart';
import '../models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_auth/local_auth.dart'; // Importa local_auth
import 'package:logger/logger.dart';
import '../services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/secure/secure_storage.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import '../helpers/toast/toast_helper.dart';
import '../helpers/connectivity/connectivity_helper.dart';
import '../helpers/biometric/biometric_helper.dart';
import '../services/logs/log.servic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final logService = LogService();
  final SecureStorageService storageService = SecureStorageService();
  // Variable para almacenar la suscripción de la conectividad
  StreamSubscription<List<ConnectivityResult>>? subscription;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final LocalAuthentication _auth =
      LocalAuthentication(); // Instancia de LocalAuthentication
  final toastsHelper = ToastsHelper();
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _opacityAnimation;
  bool _hidePassword = true;
  bool _isLoading = false;
  bool _isLoadingBiometric = false;
  final bool _shouldAuthenticate = true;
  final appState = AppState();

  //Instancia para leer token JWT
  final authService = AuthService(baseUrl: dotenv.env['BASE_URL']);
  // Para saber si el campo ha sido tocado
  bool _userTouched = false;
  bool _passwordTouched = false;
  late final String? baseUrl;

  // Método para guardar el token
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LogService.log('Obteniendo instancia de SharedPreferences',
        level: Level.debug);
    // Guardamos el token en SharedPreferences
    await prefs.setString('auth_token', token);
    LogService.log('Token guardado exitosamente', level: Level.info);
  }

  @override
  void initState() {
    baseUrl = dotenv.env['BASE_URL'];
    LogService.log('Iniciando el initState del screen login',
        level: Level.trace);
    super.initState();
    biomtricStorage();
    LogService.log('Iniciando la pantalla de login', level: Level.trace);

    LogService.log('Cargando controlador de animación', level: Level.trace);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    LogService.log('Cargando controlador de opacidad de animación',
        level: Level.trace);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    LogService.log('Verificando el servicio de huella..', level: Level.trace);
    try {
      _initializeAsync();
      LogService.log('Inicialización del servicio de huella completada',
          level: Level.info);
    } catch (e) {
      LogService.log('Error al inicializar el servicio de huella: \$e',
          level: Level.error);
    }

    _animationController.forward();
    LogService.log('Realizando suscripción de conectividad',
        level: Level.trace);
    subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.contains(ConnectivityResult.none)) {
          LogService.log('Sin conexión a internet detectada',
              level: Level.warning);
          toastsHelper.customToast('Sin conexión a internet', ColorType.red);
        } else if (results.contains(ConnectivityResult.wifi)) {
          LogService.log('Conectado a red Wi-Fi', level: Level.info);
          toastsHelper.customToast('Conectado a red Wi-Fi', ColorType.blue);
        } else if (results.contains(ConnectivityResult.mobile)) {
          LogService.log('Conectado a red móvil', level: Level.info);
          toastsHelper.customToast('Conectado a red móvil', ColorType.blue);
        }
      },
    );
  }

  Future<void> biomtricStorage() async {
    //Nota esta seteado al revez pero funciona
    final owner = await storageService.readMap('owner');
    if (owner?['biometric'] == 'on') {
      appState.setUseBiometrics(false);
    }
    if (owner?['biometric'] == 'off') {
      appState.setUseBiometrics(true);
    }
  }

  Future<dynamic> _initializeAsync() async {
    LogService.log('Verificando que el token sea válido', level: Level.trace);
    try {
      bool isValid = await authService.isTokenValid();
      if (!isValid) {
        LogService.log(
            'El token ha expirado, inicializando autenticación biométrica...',
            level: Level.warning);
        checkBiometricWhenAppStarts();
      }
    } catch (e) {
      LogService.log('Error al verificar el token: \$e', level: Level.error);
    }
  }

  Future<bool> _checkBiometricAvailability() async {
    LogService.log('Revisando capacidad biométrica en el dispositivo...',
        level: Level.trace);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final secureStorageService = SecureStorageService();
      final owner = await secureStorageService.readMap('owner');
      LogService.log('Verificando preferencias de usuario', level: Level.trace);

      bool isBiometricPreferenceOn = owner?['biometric'] == 'on';
      bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;

      if (canAuthenticateWithBiometrics) {
        List<BiometricType> availableBiometrics =
            await _auth.getAvailableBiometrics();
        LogService.log('El dispositivo tiene capacidad biométrica',
            level: Level.debug);

        if (availableBiometrics.isNotEmpty && isBiometricPreferenceOn) {
          LogService.log('Puede usarse biometría', level: Level.info);
          appState.setUseBiometrics(true);
          return true;
        } else {
          LogService.log(
              'No puede usarse biometría por preferencias de usuario',
              level: Level.warning);
          appState.setUseBiometrics(false);
          return false;
        }
      } else {
        LogService.log('El dispositivo no tiene capacidad biométrica',
            level: Level.warning);
        appState.setUseBiometrics(false);
        return false;
      }
    } catch (e) {
      LogService.log('Error al revisar disponibilidad biométrica: \$e',
          level: Level.error);
      return false;
    }
  }

  Future<void> checkBiometric() async {
    LogService.log('Revisando capacidad biometrica...', level: Level.trace);
    final isActiveBiometric = await _checkBiometricAvailability();
    if (isActiveBiometric) {
      biometricEnabled();
    }
  }

  @override
  void dispose() {
    // Cancelar la suscripción para evitar fugas de memoria
    LogService.log('Dispocisionando susbscripciones de widget login ',
        level: Level.trace);
    subscription?.cancel();
    _userFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Función para verificar si la huella dactilar debe solicitarse solo la primera vez
  void checkBiometricWhenAppStarts() async {
    LogService.log('Revisando si existe provienes del logout...',
        level: Level.trace);
    LogService.log('Realizando instancia de flutter sharedPreferences',
        level: Level.trace);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LogService.log('Obtencion de variable booleana desde sharedPreferences',
        level: Level.trace);
    bool? wasLoggedOut = prefs.getBool('wasLoggedOut') ?? false;
    if (_shouldAuthenticate && !wasLoggedOut) {
      // Lógica para mostrar la autenticación biométrica
      LogService.log('No provienes del logout, iniciando auth por biometria');
      checkBiometric();
    }
    LogService.log('Se restablece la variable bool en sharedPreferences',
        level: Level.trace);
    // Restablecer la bandera después de manejar el estado inicial
    prefs.setBool('wasLoggedOut', false);
  }

  void togglePasswordVisibility() {
    LogService.log('Se restablece la variable bool en sharedPreferences',
        level: Level.trace);
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  bool _isFormValid() {
    LogService.log('Comprobando si los input cumplen con los requisitos',
        level: Level.trace);
    // Verifica que los campos no estén vacíos y que tengan más de 3 caracteres
    return _userController.text.isNotEmpty &&
        _userController.text.length > 3 &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length > 3;
  }

  _checkConnectivity() async {
    LogService.log('Revisando conectividad...', level: Level.trace);
    bool isConnected = await ConnectivityHelper.checkConnectivity();
    return isConnected;
  }

  _authenticateWithBiometrics() async {
    LogService.log('Servicio de biometria en ejecucion', level: Level.trace);
    final biometricHelper = BiometricHelper();
    bool isAuthenticated =
        await biometricHelper.authenticateWithBiometrics(context);
    return isAuthenticated;
  }

  createOwner(String user, String password) async {
    LogService.log('Creacion de usuario de tipo Owner en curso...',
        level: Level.trace);
    final secureStorageService = SecureStorageService();
    return secureStorageService.writeMap('owner', {
      'username': user,
      'password': password,
      'biometric': 'off',
      'modal': 'off',
      'mobileData': 'off'
    });
  }

  Future<Map<String, String>> checkStorage(String user, String password) async {
    LogService.log('Revisando secure storage para buscar usuarios',
        level: Level.trace);
    try {
      // Consulta en el almacenamiento si existe un owner
      LogService.log('Buscando usuario tipo Owner', level: Level.trace);
      final owner = await storageService.readMap('owner');
      final currentUser = await storageService.readMap('currentUser');
      // Si no hay un owner, crea uno nuevo owner
      if (owner == null || owner.isEmpty) {
        LogService.log('No se encontro un usuario tipo owner',
            level: Level.trace);
        await createOwner(user, password);

        // Leemos el nuevo owner creado
        LogService.log('Obtenemos el nuevo usuario creado', level: Level.trace);
        final newOwner = await storageService.readMap('owner');

        LogService.log('El nuevo user ahora sera tambien el currentUser',
            level: Level.trace);

        // Guardamos el nuevo owner como currentUser verificando que no sea nulo
        if (newOwner != null) {
          final ownerUser = {
            'username': newOwner['username'] ?? '',
            'password': newOwner['password'] ?? '',
            'biometric': newOwner['biometric']!,
            'modal': newOwner['modal']!,
            'mobileData': newOwner['mobileData']!
          };
          await storageService.writeMap('currentUser', ownerUser);
          return ownerUser;
        } else {
          // Manejo en caso de que newOwner sea nulo
          throw Exception('newOwner es nulo');
        }
      } else {
        LogService.log('Owner econtrado assignando nuevo user como guest',
            level: Level.trace);
        // Si no es nulo quiere decir que ya existe un owner, para lo que crea un usuario tipo guest
        final guestUser = {
          'username': user,
          'password': password,
          'biometric': 'off',
          'modal': 'off',
          'mobileData': 'off'
        };

        // Al ya existir un owner antes de crear un guest se verifica si el guest es el owner
        if (guestUser['username'] == owner['username']) {
          // Si el guest es el owner se guarda el owner como currentUser con los valores del owner
          LogService.log('Comprobando que el guest user no sea el owner',
              level: Level.trace);
          await storageService.writeMap('currentUser', owner);
          return owner;
        }
        if (guestUser['username'] == currentUser?['username']) {
          return currentUser!;
        } else {
          // En caso que el guest no sea el owner se crea un usuario guest
          LogService.log('Realizando owner al guest', level: Level.trace);
          await storageService.writeMap('currentUser', guestUser);
          return guestUser;
        }
      }
    } catch (e) {
      throw Exception('Error en checkStorage: $e');
    }
  }

  void biometricEnabled() {
    LogService.log('Verificando plataforma movil...', level: Level.trace);
    if (Platform.isAndroid) {
      LogService.log('Plataforma Android detecada', level: Level.trace);
      final secureStorage = SecureStorageService();
      LogService.log('Inciando servicios biometricos', level: Level.trace);
      _authenticateWithBiometrics().then((isAuthenticated) {
        if (isAuthenticated) {
          LogService.log('Biometria autenticada con exito', level: Level.trace);
          secureStorage.readMap('owner').then((data) {
            if (data != null) {
              checkStorage(data['username']!, data['password']!);
              submitBiometric(data['username'], data['password']);
              LogService.log('Realizando un login biometrico...',
                  level: Level.trace);
            }
          });
        }
      });
    } else {
      LogService.log('Plataforma Ios detectada', level: Level.trace);
      final faceIdHelper = FaceIdHelper();
      LogService.log('Iniciando servicios biometricos', level: Level.trace);
      faceIdHelper.authenticateWithFaceID().then((isAuthenticated) async {
        if (isAuthenticated) {
          LogService.log('Biometria autenticada con exito', level: Level.trace);
          final secureStorage = SecureStorageService();
          final data = await secureStorage.readMap('owner');
          if (data != null) {
            checkStorage(data['username']!, data['password']!);
            submitBiometric(data['username'], data['password']);
            LogService.log('Realizando un login con huella digital...',
                level: Level.trace);
          }
        }
      });
    }
  }

  submit(String method) async {
    // Verifica la conectividad antes de proceder
    LogService.log('Inicio de sesion con datos biometricos',
        level: Level.trace);
    bool isConnected = await _checkConnectivity();
    LogService.log('Verificando si tenemos conexion a internet',
        level: Level.trace);
    if (!isConnected) return;
    if (method == 'password') {
      String user = _userController.text;
      String password = _passwordController.text;

      // print('Las credenciales son $user y $password');

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      LogService.log('message: Iniciando sesión con usuario $user');
      try {
        AuthService authService = AuthService(baseUrl: baseUrl);
        dynamic responseUser = await authService.login(user, password);

        if (responseUser.isNotEmpty && responseUser != "Error") {
          toastsHelper.customToast(
              'Inicio de sesión correcto!', ColorType.blue);
          LogService.log(
              'Inicio de sesión correcto - se guarda el responseUser');
          LogService.log('Revisando credenciales y storage');
          // await checkStorage(user, password);
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            LogService.log('Autenticacion validad con exito');
            LogService.log('Redirigiendo a home');

            Navigator.pushNamed(context, '/home');
          }
        } else {
          toastsHelper.customToast('Credeciales incorrectas', ColorType.red);
          LogService.log('Intento de autorizacion fallido');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        LogService.log('No fue exitoso el login por contraseña',
            level: Level.trace);
        toastsHelper.customToast('Ocurrió un error: $e', ColorType.red);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    if (method == 'biometric') {
      LogService.log('Verificando plataforma movil...', level: Level.trace);
      if (Platform.isAndroid) {
        LogService.log('Plataforma Android detecada', level: Level.trace);
        final secureStorage = SecureStorageService();
        LogService.log('Inciando servicios biometricos', level: Level.trace);
        _authenticateWithBiometrics().then((isAuthenticated) {
          if (isAuthenticated) {
            LogService.log('Biometria autenticada con exito',
                level: Level.trace);
            secureStorage.readMap('owner').then((data) {
              if (data != null) {
                checkStorage(data['username']!, data['password']!);
                submitBiometric(data['username'], data['password']);
                LogService.log('Realizando un login biometrico...',
                    level: Level.trace);
              }
            });
          } else {
            LogService.log('Lanzando toast de auth fallida',
                level: Level.trace);
            toastsHelper.customToast(
                "Autenticación con huella fallida.", ColorType.red);
          }
        });
      } else {
        LogService.log('Plataforma Ios detectada', level: Level.trace);
        final faceIdHelper = FaceIdHelper();
        LogService.log('Iniciando servicios biometricos', level: Level.trace);
        faceIdHelper.authenticateWithFaceID().then((isAuthenticated) async {
          if (isAuthenticated) {
            LogService.log('Biometria autenticada con exito',
                level: Level.trace);
            final secureStorage = SecureStorageService();
            final data = await secureStorage.readMap('owner');
            if (data != null) {
              checkStorage(data['username']!, data['password']!);
              submitBiometric(data['username'], data['password']);
              LogService.log('Realizando un login con faceID...',
                  level: Level.trace);
            }
          } else {
            LogService.log('Lanzando toast de auth fallida',
                level: Level.trace);
            toastsHelper.customToast(
                "Autenticación con Face ID fallida.", ColorType.red);
          }
        });
      }
    }
  }

  void submitBiometric(userCredential, passwordCredential) async {
    LogService.log(
        'Click en submit - Intento de inicio de sesión via biometrica');
    // Verifica la conectividad antes de proceder
    LogService.log('Verificando si tenemos conexion', level: Level.trace);
    bool isConnected = await _checkConnectivity();
    if (!isConnected) return;

    String user = userCredential;
    String password = passwordCredential;
    LogService.log('Se activa el loader de carga', level: Level.trace);
    setState(() {
      _isLoadingBiometric = true;
    });
    LogService.log(
        'Solicitud de login al backend saliente con el usuario $user',
        level: Level.trace);
    AuthService authService = AuthService(baseUrl: baseUrl);
    String? token = await authService.login(user, password);

    LogService.log('Comprobando autenticidad...', level: Level.trace);
    // Si el token es null, significa que el login falló
    if (token.isNotEmpty && token != "Error") {
      toastsHelper.customToast("Validado con exito!");
      LogService.log('Se validaron con exito las credenciales',
          level: Level.trace);
      setState(() {
        _isLoadingBiometric = false;
      });

      if (mounted) {
        Navigator.pushNamed(context, '/home');
      }
    } else {
      LogService.log('Las credenciales no son correctas', level: Level.trace);
      toastsHelper.customToast("Credenciales incorrectas", ColorType.red);

      setState(() {
        _isLoadingBiometric = false;
      });
    }
  }

  messageBiometric() {
    final toastHelper = ToastsHelper();
    LogService.log('Toast para solicitar credenciales saliente',
        level: Level.trace);
    return toastHelper.customToast(
        'Porfavor ingresa tus credenciales', ColorType.blue);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fondo con gradiente para una apariencia más moderna
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
                      "assets/images/Resetpassword2.gif",
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenedor del formulario con diseño mejorado
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Parte superior con diseño mejorado
                  Container(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
                    child: Column(
                      children: [
                        // Título con efecto decorativo
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Círculo decorativo detrás del texto
                              Positioned(
                                bottom: 1,
                                child: Container(
                                  height: 12,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Text(
                                "Autenticación",
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Subtítulo con línea decorativa
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 5,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Parte del formulario con diseño mejorado
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              // Campo de usuario con estilo mejorado
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _userController,
                                  focusNode: _userFocusNode,
                                  onChanged: (_) => setState(() {
                                    _userTouched = true;
                                  }),
                                  decoration: InputDecoration(
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.5),
                                    filled: true,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      size: 22,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    labelText: 'Usuario',
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
                                            .secondary
                                            .withValues(alpha: 0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        width: 2.0,
                                      ),
                                    ),
                                    errorText: _userTouched &&
                                            (_userController.text.isEmpty ||
                                                _userController.text.length <=
                                                    3)
                                        ? '⚠️  Debe tener más de 3 caracteres'
                                        : null,
                                    errorStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Campo de contraseña con estilo mejorado
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _hidePassword,
                                  onChanged: (_) => setState(() {
                                    _passwordTouched = true;
                                  }),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  decoration: InputDecoration(
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.5),
                                    filled: true,
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    labelText: 'Contraseña',
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        width: 2.0,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      size: 22,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                    ),
                                    errorText: _passwordTouched &&
                                            (_passwordController.text.isEmpty ||
                                                _passwordController
                                                        .text.length <=
                                                    3)
                                        ? '⚠️  Debe tener más de 3 caracteres'
                                        : null,
                                    errorStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),

                              // Botón de inicio de sesión con estilo mejorado
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isFormValid()
                                      ? () => submit('password')
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid()
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Colors.grey.shade400,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: _isFormValid() ? 5 : 0,
                                    shadowColor: _isFormValid()
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSecondary
                                            .withValues(alpha: 0.5)
                                        : Colors.transparent,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          strokeWidth: 3,
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Iniciar sesión",
                                            style: TextStyle(
                                              color: _isFormValid()
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                  : const Color.fromARGB(
                                                          255, 99, 99, 99)
                                                      .withValues(
                                                          alpha:
                                                              0.6), // Color de texto consistente
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de huella flotante con estilo mejorado
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: appState.useBiometrics
                      ? () => submit('biometric')
                      : () => messageBiometric(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appState.useBiometrics
                        ? Theme.of(context).colorScheme.onPrimary
                        : appState.isDarkMode
                            ? const Color.fromARGB(255, 63, 63, 63)
                            : const Color.fromARGB(255, 218, 218, 218),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    elevation: appState.useBiometrics ? 0 : 0,
                  ),
                  child: _isLoadingBiometric
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onSurface,
                          strokeWidth: 3,
                        )
                      : Icon(
                          Platform.isAndroid ? Icons.fingerprint : Icons.face,
                          color: appState.useBiometrics
                              ? const Color.fromARGB(255, 92, 60, 60)
                              : Colors.grey,
                          size: 32,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
