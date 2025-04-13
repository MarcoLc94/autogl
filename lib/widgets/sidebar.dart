import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SidebarMenu extends StatefulWidget {
  final Function(int) onItemSelected; // Callback para manejar la selección
  final int selectedIndex; // Índice seleccionado desde el padre

  const SidebarMenu({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  SidebarMenuState createState() => SidebarMenuState();
}

class SidebarMenuState extends State<SidebarMenu> {
  bool _isMenuExpanded =
      false; // Estado para controlar si el submenú está expandido
  late final Future<String?> role;
  late String? userSesion = "";

  Future<String?> getRoleFromShared() async {
    final shared = await SharedPreferences.getInstance();
    final role = shared.getString('roles');
    userSesion = shared.getString('userSesion');
    return role;
  }

  @override
  void initState() {
    final shared = SharedPreferences.getInstance();
    super.initState();
    role = getRoleFromShared();
    print("El role del user es: $role");
    // Inicializar el estado de expansión basado en el selectedIndex
    _isMenuExpanded = widget.selectedIndex == 1 || widget.selectedIndex == 2;

    getRoleFromShared();
  }

  @override
  void didUpdateWidget(covariant SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el estado de expansión si el selectedIndex cambia
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {
        _isMenuExpanded =
            widget.selectedIndex == 1 || widget.selectedIndex == 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color:
            Theme.of(context).colorScheme.onSurface, // Color de fondo dinámico
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Título y logo
            Container(
              alignment: Alignment.center, // Centra el contenido
              padding: const EdgeInsets.symmetric(
                  horizontal: 14), // Padding horizontal
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Text(
                  //   "Auto Elite",
                  //   style: TextStyle(
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.bold,
                  //     color: Theme.of(context)
                  //         .colorScheme
                  //         .primary, // Color dinámico
                  //   ),
                  // ),
                  // Imagen estática al lado del título
                  // Transform.translate(
                  //   offset: Offset(0, -10),
                  //   child: Image.asset(
                  //     "assets/images/coffe_static_transparent.png",
                  //     width: 60,
                  //     height: 60,

                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 0),
            // Menú "Home"
            ListTile(
              leading: Icon(
                Symbols.user_attributes,
                color: Colors.white,
                size: 36, // Ajusta el tamaño según necesites
              ),
              title: Text(
                'Perfil de usuario',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface, // Color de fondo
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
                boxShadow: [
                  // Sombra opcional
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: FutureBuilder<String?>(
                future: SharedPreferences.getInstance()
                    .then((prefs) => prefs.getString('userSesion')),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Carga en curso
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Text("Error al cargar el usuario");
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          Symbols.people,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        title: Text(
                          "Nombre de usuario: ${snapshot.data}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            // Lista de elementos del menú
            Expanded(
              child: FutureBuilder<String?>(
                future: role,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final role = snapshot.data;
                    return ListView(
                      children: [
                        _buildListTile(
                          index: 0,
                          icon: Symbols.directions_car,
                          title: 'Ordenes de Compra',
                        ),
                        _buildListTile(
                          index: 1,
                          icon: Symbols.inventory,
                          title: 'Catálogo de Productos',
                        ),
                        _buildListTile(
                          index: 2,
                          icon: Symbols.person,
                          title: 'Mi Perfil',
                        ),
                        if (role == 'admin') ...[
                          // Opciones solo para administrador
                          _buildListTile(
                            index: 3,
                            icon: Symbols.local_shipping,
                            title: 'Gestión de Pedidos',
                          ),
                          _buildListTile(
                            index: 4,
                            icon: Symbols.bar_chart,
                            title: 'Reportes',
                          ),
                        ],
                        _buildListTile(
                          index: 5,
                          icon: Symbols.settings,
                          title: 'Configuración',
                        ),
                        _buildListTile(
                          index: 6,
                          icon: Symbols.logout,
                          title: 'Cerrar Sesión',
                        ),
                      ],
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Método para construir un ListTile con estilos condicionales
  Widget _buildListTile({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return Container(
      width: double.infinity, // Ocupa el 100% del ancho
      color: isSelected
          ? Theme.of(context).colorScheme.secondary
          : Colors.transparent,
      child: ListTile(
        contentPadding:
            EdgeInsets.only(left: 16.0), // Ajusta el padding izquierdo
        leading: Icon(
          icon,
          size: 30,
          color: Theme.of(context).colorScheme.onSurface,
          weight: 500, // Color dinámico
        ),
        title: Text(
          title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, // Color dinámico
              fontSize: 20,
              fontWeight: FontWeight.w400),
        ),
        onTap: () {
          widget.onItemSelected(index); // Llama al callback
        },
      ),
    );
  }

  // Método para construir un ítem de submenú
  Widget buildSubmenuItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return Container(
      width: double.infinity, // Ocupa el 100% del ancho
      color: isSelected ? Color(0xFF79a341) : Colors.transparent,
      child: ListTile(
        contentPadding:
            EdgeInsets.only(left: 40.0), // Añade más padding para el submenú
        leading: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, // Color dinámico
            fontSize: 18,
          ),
        ),
        onTap: () {
          widget.onItemSelected(index); // Llama al callback
        },
      ),
    );
  }
}
