import 'package:autogl/screens/dashboard_screen.dart';
import 'package:autogl/screens/delivery_screen.dart';
import 'package:autogl/screens/forget_password_screen.dart';
import 'package:autogl/screens/login_screen.dart';
import 'package:autogl/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import './models/app_state.dart';
import './screens/layout_screen.dart';
import './screens/first_screen.dart';

Future main() async {
  //dotenv para enviroments
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(create: (context) => AppState(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Obtener el tema base (light/dark)
        final ThemeData baseTheme =
            appState.isDarkMode ? _buildDarkTheme() : _buildLightTheme();

        // Combinar con las personalizaciones del cursor
        final ThemeData finalTheme = baseTheme.copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: baseTheme.colorScheme.onPrimary,
            selectionColor:
                baseTheme.colorScheme.onPrimary.withValues(alpha: 0.3),
            selectionHandleColor: baseTheme.colorScheme.onPrimary,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: finalTheme, // Usar el tema combinado
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => FirstScreen(),
            '/home': (context) => LayoutScreen(),
            '/login': (context) => LoginScreen(),
            '/forget_password': (context) => const ForgetPasswordScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/tools': (context) => const DeliveryScreen()
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(
          color: Colors.black, fill: 0, weight: 300, opticalSize: 48),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.light(
        primary: const Color.fromRGBO(22, 67, 127, 1), // Azul primario
        primaryContainer: const Color.fromRGBO(15, 50, 100, 1),
        secondary: const Color(0xFFFCD52F), // Amarillo secundario
        secondaryContainer: Color.fromRGBO(22, 67, 127, 1),
        surface: const Color.fromARGB(255, 236, 236, 236), // Blanco suave
        error: const Color.fromRGBO(219, 84, 97, 1), // Rojo coral
        onPrimary: const Color(0xFFF5F5F5), // Blanco no absoluto
        onSecondary: const Color(0xFF333333), // Negro suave
        onSurface: const Color(0xFF222222), // Texto principal
        onSurfaceVariant: Color.fromRGBO(22, 67, 127, 1), // Texto secundario
        onError: const Color(0xFFF5F5F5),
        inversePrimary: const Color.fromARGB(255, 201, 178, 78),
        onPrimaryFixed: const Color.fromARGB(255, 226, 226, 226),
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Componentes adicionales
      cardTheme: CardTheme(
        color: const Color.fromARGB(255, 243, 243, 243),
        elevation: 1,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(
          color: Color(0xFFFCE56F), fill: 0, weight: 300, opticalSize: 48),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color.fromARGB(255, 59, 59, 59), // Azul más claro
        primaryContainer: const Color.fromRGBO(22, 67, 127, 1),
        secondary: const Color(0xFFFFDF60), // Amarillo más suave
        secondaryContainer: const Color.fromARGB(255, 201, 178, 78),
        surface: const Color(0xFF121212), // Casi negro
        error: const Color.fromRGBO(239, 104, 117, 1), // Rojo más brillante
        onPrimary: const Color(0xFFEEEEEE), // Blanco suave
        onSecondary: const Color(0xFF222222), // Negro suave
        onSurface: const Color.fromARGB(255, 56, 56, 56), // Texto principal
        onSurfaceVariant:
            const Color.fromARGB(255, 224, 224, 224), // Texto secundario
        onError: const Color.fromARGB(255, 97, 97, 97),
        inversePrimary: const Color.fromARGB(255, 201, 178, 78),
        onPrimaryFixed: const Color.fromARGB(255, 80, 80, 80),
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardTheme(
        color: const Color(0xFF222222),
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // Componentes adicionales
    );
  }
}
