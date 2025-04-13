import 'package:autogl/screens/dashboard_screen.dart';
import 'package:autogl/screens/delivery_screen.dart';
import 'package:autogl/widgets/sidebar.dart';
import '../services/secure/secure_storage.dart';
import 'package:logger/logger.dart';
import './purchase_screen.dart';
import '../services/logs/log.servic.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../widgets/navabar.dart';
import 'dart:async';
import '../helpers/toast/toast_helper.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => LayoutScreenState();
}

class LayoutScreenState extends State<LayoutScreen> {
  int selectedPageIndex = 0;
  final toastsHelper = ToastsHelper();
  bool isModalOpen = false; // Indica si un modal ya está abierto
  BuildContext? activeModalContext; // Contexto del modal activo

  Future<String> checkUserRole() async {
    // try {
    //   SharedPreferences preferences = await SharedPreferences.getInstance();

    //   final jsonUserData = preferences.getString("userInfo");

    //   if (jsonUserData == null) {
    //     throw Exception(
    //         "No se encontró información del usuario en SharedPreferences");
    //   }

    //   // Decodificar la cadena JSON
    //   final userData = json.decode(jsonUserData);
    //   print("Dentro del layout userdata es: $userData");
    //   // Verificar si userData es un Map y contiene la clave 'role'
    //   if (userData is Map<String, dynamic> && userData.containsKey('roles')) {
    //     preferences.setString("roles", userData['roles'][0]);
    //     LogService.log(
    //         "El usuario a logeado con el role: ${userData['roles'][0]}",
    //         level: Level.info);
    //     return userData['roles'][0]; // Retornar el rol del usuario
    //   } else {
    //     throw Exception("El JSON no contiene la clave 'role'");
    //   }
    // } catch (e) {
    //   // Manejar cualquier excepción que ocurra
    //   throw Exception("Error al decodificar el JSON: $e");
    // }
    return "owner";
  }

  // Mapa de índices a widgets
  final List<Widget> _pages = [
    PurchaseScreen(),
    DashboardScreen(),
    DeliveryScreen()
  ];

  // Cambiar de página
  void _selectPage(int index) {
    LogService.log('Cambiando index de pagina en layout', level: Level.debug);
    setState(() {
      selectedPageIndex = index;
    });
  }

  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void initState() {
    super.initState();
    checkConnection();
    checkUserRole();
    LogService.log('Iniciando widget de layout', level: Level.trace);
    // Suscribirse al flujo de cambios en la conectividad
    LogService.log('Montando connectividad global', level: Level.trace);
    subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.contains(ConnectivityResult.none)) {
          LogService.log('No hay conexion', level: Level.trace);
          // toastsHelper.customToast(
          //   'No hay conexión a Internet',
          //   ColorType.red,
          // );
          closeActiveModal('null');
        } else if (results.contains(ConnectivityResult.wifi)) {
          LogService.log('Conexion por wifi establecido', level: Level.trace);
          closeActiveModal('wifi');
        } else if (results.contains(ConnectivityResult.mobile)) {
          LogService.log('Conexion por red movil', level: Level.trace);
          // toastsHelper.customToast(
          //   'Conectado a red móvil',
          //   ColorType.blue,
          // );
          closeActiveModal('data');
          showDataConnectionModal();
        }
      },
    );
  }

  checkConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    _checkAndReplaceLayout();

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      LogService.log('Conexion por red movil', level: Level.trace);
      showDataConnectionModal();
    }

    if (connectivityResult.contains(ConnectivityResult.none)) {
      // NO network available.
      LogService.log('Sin conexión a internet', level: Level.fatal);
    }
  }

  void showDataConnectionModal() async {
    final secureStorageService = SecureStorageService();
    final currentUser = await secureStorageService.readMap('currentUser');
    if (!isModalOpen && currentUser?['mobileData'] != 'on') {
      isModalOpen = true;
      showDialog(
        context: context,
        builder: (context) {
          activeModalContext = context;
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
                      'Conexión con datos móviles',
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
                      'Ahora estás conectado con datos móviles. ¿Deseas continuar?',
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
                          Navigator.of(context).pop();
                          isModalOpen = false;
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xFF79a341),
                            shape: RoundedRectangleBorder()),
                        child: Text(
                          'Sí',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          isModalOpen = false;
                          showWifiConnectionModal();
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder()),
                        child: Text(
                          'No',
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
      );
    }
  }

  void showWifiConnectionModal() {
    if (!isModalOpen) {
      isModalOpen = true;
      showDialog(
        context: context,
        barrierDismissible: true, // No permite cerrar tocando fuera del modal
        builder: (BuildContext modalContext) {
          // Asigna el contexto del modal
          activeModalContext = modalContext;
          return PopScope(
            canPop: false, // Bloquea el botón de retroceso
            child: Dialog(
              backgroundColor: Colors.transparent, // Fondo transparente
              insetPadding: EdgeInsets.all(0), // Sin padding en los bordes
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: Color(0xFF79a341),
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Sin conexión a internet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Para continuar, conéctate a una red Wi-Fi o datos móviles',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void closeActiveModal(method) {
    if (activeModalContext != null && isModalOpen) {
      try {
        Navigator.of(activeModalContext!).pop();
        if (method == 'wifi') {
          method == 'wifi'
              ? toastsHelper.customToast(
                  'Conexión restablecida con wi-fi', ColorType.blue)
              : toastsHelper.customToast(
                  'Conexión restablecida con Datos móviles', ColorType.blue);
        }
      } catch (e) {
        LogService.log('Error al cerrar el modal: $e', level: Level.fatal);
      } finally {
        // Restablece las variables
        activeModalContext = null;
        isModalOpen = false;
      }
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  void _checkAndReplaceLayout() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      // Si hay pantallas en la pila, las eliminamos hasta la raíz
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    // Reemplazamos la pantalla actual por la misma instancia del Layout
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const LayoutScreen()),
    );
  }

  @override
  void dispose() {
    LogService.log('Desmontando dependencias de layout', level: Level.trace);
// Cancelar la suscripción para evitar fugas de memoria
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(), // Barra de navegación superior
      drawer: SidebarMenu(
        onItemSelected: (index) {
          Navigator.pop(context); // Cierra el Drawer
          _selectPage(index); // Cambia de página
        },
        selectedIndex:
            selectedPageIndex, // Pasa el índice seleccionado al SidebarMenu
      ),
      body: _pages[
          selectedPageIndex], // Muestra la página correspondiente al índice
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context)
            .colorScheme
            .secondary, // Color del ítem seleccionado
        unselectedItemColor: Theme.of(context)
            .colorScheme
            .onPrimary, // Color de los ítems no seleccionados
        currentIndex: selectedPageIndex, // Índice seleccionado
        onTap: _selectPage, // Cambia de página al tocar un ícono
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Envios',
          ),
        ],
      ),
    );
  }
}
