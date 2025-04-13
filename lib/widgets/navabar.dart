import 'package:autogl/widgets/generic_toggle.dart';
import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final AuthService authService =
      AuthService(baseUrl: 'https://learn.bitfarm.mx/api');

  Future<Map<String, dynamic>?> getUserInfo() async {
    // SharedPreferences userData = await SharedPreferences.getInstance();
    // String? jsonString = userData.getString('userInfo');

    // // Verificar si jsonString no es nulo antes de hacer el parseo
    // if (jsonString != null) {
    //   Map<String, dynamic> userInfo = json.decode(jsonString);

    //   return userInfo;
    // } else {
    //   // Si jsonString es nulo, puedes devolver null o manejar el caso como desees
    //   return null;
    // }
    return {
      "token": "tu_token_jwt",
      "user": {
        "username": "marco",
        "last_name": "lopez",
        "roles": ["owner", "user"]
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          size: 40,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        onPressed: () => (Scaffold.of(context).openDrawer()),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: InkWell(
            onTap: () => _showUserInfoModal(context),
            child: Icon(
              Symbols.settings, // Ícono de engrane/ajustes
              size: 40, // Tamaño equivalente al que tenías
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer, // Color del ícono (ajústalo según tu diseño)
            ),
          ),
        ),
      ],
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
      // ),
    );
  }

  Size get preferredSize => const Size.fromHeight(56.0);

  // Modal con la información del usuario y botón de logout
  void _showUserInfoModal(BuildContext context) {
    // final appState = Provider.of<AppState>(context, listen: false);
    Future<void> removeToken() async {
      // Restablecer el flag de la app
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: getUserInfo(), // Asíncrono
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text('No user data found'));
            }
            Map<String, dynamic> userInfo = snapshot.data!;
            return Stack(
              children: [
                // Fondo que detecta clics fuera del modal
                GestureDetector(
                  onTap: () {
                    Navigator.pop(
                        context); // Cerrar modal al hacer clic en el fondo
                  },
                  child: Container(
                    color: Colors.transparent, // Fondo semitransparente
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Modal centrado
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        // Contenedor del modal
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                                context); // Cierra el modal si se hace clic fuera del modal
                          },
                          child: Scaffold(
                            backgroundColor: Colors
                                .transparent, // Fondo transparente para el área exterior
                            body: Center(
                              child: GestureDetector(
                                onTap:
                                    () {}, // Evitar que el tap dentro del modal cierre el modal
                                child: Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Esquinas redondeadas
                                  ),
                                  child: Stack(
                                    children: [
                                      // El contenido del modal
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        constraints: BoxConstraints(
                                          minWidth: 300,
                                          maxWidth:
                                              400, // Ancho máximo del modal
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize
                                              .min, // Tamaño dinámico según el contenido
                                          children: [
                                            // Espacio para el título
                                            Title(
                                              color: Colors.black,
                                              child: Text(
                                                "Configuracion",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SizedBox(height: 20),
                                                Column(
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/user.png",
                                                      width: 80,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      '@${userInfo['username']}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onSurfaceVariant),
                                                    ),
                                                    SizedBox(height: 10),
                                                    // Toggle para biometría
                                                    GenericToggle(
                                                      type:
                                                          ToggleType.biometric,
                                                      onChanged: (value) {
                                                        // Opcional: puedes agregar lógica adicional aquí si necesitas
                                                        // print(
                                                        //     'Biometric toggle changed to: $value');
                                                      },
                                                    ),
                                                    SizedBox(height: 20),
                                                    // Toggle para datos móviles
                                                    GenericToggle(
                                                      type:
                                                          ToggleType.mobileData,
                                                      onChanged: (value) {},
                                                    ),
                                                    SizedBox(height: 20),
                                                    // Toggle para modo oscuro
                                                    GenericToggle(
                                                      type: ToggleType.darkMode,
                                                      onChanged: (value) {},
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 40),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              '${userInfo['name']}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurfaceVariant),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 30),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.email,
                                                            size: 20,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              '${userInfo['email']}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurfaceVariant),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.fingerprint,
                                                            size: 24,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Expanded(
                                                            child: Text(
                                                              'Inicio con huella',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurfaceVariant),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.network_cell,
                                                            size: 24,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Expanded(
                                                            child: Text(
                                                              'Datos móviles',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurfaceVariant),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 30),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.dark_mode,
                                                            size: 24,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Expanded(
                                                            child: Text(
                                                              'Dark Mode',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurfaceVariant),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Botón "Cerrar sesión"
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  style: ButtonStyle(
                                                    side:
                                                        WidgetStateProperty.all(
                                                      BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    shape:
                                                        WidgetStateProperty.all(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                    ),
                                                    minimumSize:
                                                        WidgetStateProperty.all(
                                                      const Size(
                                                          double.infinity,
                                                          50), // Ancho al 100%
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    // Lógica para cerrar sesión
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    await prefs.setBool(
                                                        'wasLoggedOut', true);
                                                    removeToken();
                                                    if (!mounted) return;
                                                    Navigator.pop(
                                                        context); // Cerrar el modal
                                                    Navigator
                                                        .pushReplacementNamed(
                                                            context, '/');
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .power_settings_new,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Cerrar sesión',
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Ícono de cierre en la esquina superior derecha del modal
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(
                                                context); // Cierra el modal al hacer clic
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 35,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
