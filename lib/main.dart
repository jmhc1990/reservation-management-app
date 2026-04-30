import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'firebase_options.dart'; // Generado por flutterfire configure
import 'navigation/auth_wrapper.dart';
import 'core/theme/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // Inicializar formato de fechas en español
 
  // Inicializar Firebase antes de arrancar la app.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 
  runApp(const BarberApp());
}
 
class BarberApp extends StatelessWidget {
  const BarberApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthController se crea una sola vez y vive toda la app.
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
        ],
        locale: const Locale('es', 'ES'), // Establecer español como idioma predeterminado
        title: 'Barber App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.darkBackground,
          ),
          scaffoldBackgroundColor: AppColors.darkBackground,
        ),
        // AuthWrapper decide automáticamente si mostrar Login o Home.
        home: const AuthWrapper(),
      ),
    );
  }
}
