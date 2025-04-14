import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SidebarMenu extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const SidebarMenu({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  SidebarMenuState createState() => SidebarMenuState();
}

class SidebarMenuState extends State<SidebarMenu> {
  // late final Future<Map<String, String?>> userInfo;
  late final Future<String?> userInfo;
  bool _isCompanyExpanded = false;

  // Lista de empresas (simulada)
  final List<String> companies = ['Auto Elite'];
  String selectedCompany = 'Auto Elite';

  // Future<Map<String, String?>> getUserInfoFromShared() async {
  //   final shared = await SharedPreferences.getInstance();
  //   return {
  //     'role': shared.getString('roles'),
  //     'username': shared.getString('userSesion'),
  //     'email': shared.getString('userEmail') ??
  //         'usuario@ejemplo.com', // Email simulado
  //     'fullName': shared.getString('fullName') ??
  //         'Usuario Ejemplo', // Nombre completo simulado
  //   };
  // }

  Future<String?> getUserInfoFromShared() async {
    final shared = await SharedPreferences.getInstance();
    final userInfoString = shared.getString('userInfo');

    return userInfoString != null ? jsonDecode(userInfoString) : null;
  }

  @override
  void initState() {
    super.initState();
    userInfo = getUserInfoFromShared();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    // Colores para el sidebar
    final drawerBackgroundColor =
        isDarkMode ? colorScheme.primary : colorScheme.onSurfaceVariant;

    final textColor = isDarkMode ? colorScheme.onPrimary : Colors.white;

    final iconColor = isDarkMode ? colorScheme.onSurfaceVariant : Colors.white;

    final userCardColor = isDarkMode
        ? Color.fromARGB(255, 75, 75, 75)
        : Color.fromARGB(255, 42, 87, 147);

    Future<void> removeToken() async {
      // Restablecer el flag de la app
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }

    logout(context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('wasLoggedOut', true);
      removeToken();
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/');
    }

    return Drawer(
      child: Container(
        color: drawerBackgroundColor,
        child: Column(
          children: [
            // Cabecera con perfil de usuario
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 16),
              color: drawerBackgroundColor,
              child: Column(
                children: [
                  // Título de Perfil de Usuario
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Symbols.account_circle,
                          color: textColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Perfil de Usuario',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tarjeta de información del usuario
            FutureBuilder<String?>(
              future: userInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Text("Error al cargar información",
                      style: TextStyle(color: textColor));
                } else {
                  final userData = snapshot.data!;
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: userCardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar y nombre de usuario
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.secondary,
                                radius: 24,
                                child: Text(
                                  userData.isNotEmpty
                                      ? userData[0].toUpperCase()
                                      : userData,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData.isNotEmpty ? userData : 'User',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userData.isNotEmpty
                                          ? '$userData@mail.com'
                                          : 'user@example.com',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(color: Colors.white24, height: 24),

                          // Selector de empresa con dropdown
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isCompanyExpanded = !_isCompanyExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Symbols.business,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Empresa:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      selectedCompany,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Icon(
                                      _isCompanyExpanded
                                          ? Symbols.keyboard_arrow_up
                                          : Symbols.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Opciones de empresas expandibles
                          if (_isCompanyExpanded)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: companies
                                    .map((company) => InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedCompany = company;
                                              _isCompanyExpanded = false;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Text(
                                              company,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    selectedCompany == company
                                                        ? colorScheme.secondary
                                                        : Colors.white70,
                                                fontWeight:
                                                    selectedCompany == company
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Menú principal
            Expanded(
              child: FutureBuilder<String?>(
                future: userInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final role = snapshot.data;
                    return ListView(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildMenuDivider("PRINCIPAL"),
                        _buildListTile(
                          index: 0,
                          icon: Symbols.directions_car,
                          title: 'Compras',
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildListTile(
                          index: 1,
                          icon: Symbols.search,
                          title: 'Búsqueda',
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildListTile(
                          index: 2,
                          icon: Symbols.photo_library,
                          title: 'Fotos',
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildListTile(
                          index: 3,
                          icon: Symbols.local_shipping,
                          title: 'Envíos',
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        if (role == 'admin') ...[
                          _buildMenuDivider("ADMINISTRACIÓN"),
                          _buildListTile(
                            index: 4,
                            icon: Symbols.bar_chart,
                            title: 'Reportes',
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                          _buildListTile(
                            index: 5,
                            icon: Symbols.settings,
                            title: 'Configuración',
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                        ],
                      ],
                    );
                  }
                },
              ),
            ),

            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(
                    Symbols.logout,
                    color: Colors.white,
                    size: 24,
                  ),
                  title: Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // Lógica para cerrar sesión
                    logout(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir un separador de secciones en el menú
  Widget _buildMenuDivider(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Método para construir un ListTile con estilos condicionales
  Widget _buildListTile({
    required int index,
    required IconData icon,
    required String title,
    required Color textColor,
    required Color iconColor,
  }) {
    final bool isSelected = widget.selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor =
        isSelected ? colorScheme.secondary : Colors.transparent;

    final finalTextColor = isSelected ? colorScheme.onSecondary : textColor;

    final finalIconColor = isSelected ? colorScheme.onSecondary : iconColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(
          icon,
          size: 24,
          color: finalIconColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: finalTextColor,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          widget.onItemSelected(index);
        },
      ),
    );
  }
}
