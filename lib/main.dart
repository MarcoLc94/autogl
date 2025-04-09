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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appState.isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => FirstScreen(),
            '/home': (context) => LayoutScreen(),
            '/login': (context) => LoginScreen(),
            '/forget_password': (context) => const ForgetPasswordScreen(),
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromARGB(255, 218, 124, 47),
        onPrimary: Colors.white,
        secondary: Color.fromARGB(255, 163, 137, 65),
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: const Color.fromARGB(255, 141, 126, 126),
        onSurface: Colors.black,
      ),
      useMaterial3: true,
      primarySwatch: Colors.orange,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: Color.fromARGB(255, 83, 78, 67),
        onPrimary: const Color.fromARGB(255, 179, 170, 170),
        secondary: Color.fromARGB(255, 214, 98, 20),
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.grey[900]!,
        onSurface: Colors.white,
      ),
      useMaterial3: true,
      primarySwatch: Colors.orange,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
