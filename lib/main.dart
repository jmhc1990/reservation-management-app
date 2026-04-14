import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart'; // Generado por flutterfire configure
import 'navigation/auth_wrapper.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // Inicializar Firebase antes de arrancar la app.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 
  runApp(const BarberApp());
=======
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
>>>>>>> 2d9429bfe3179916bfa0c42578212622d69f5a51
}
 
class BarberApp extends StatelessWidget {
  const BarberApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // AuthController se crea una sola vez y vive toda la app.
      create: (_) => AuthController(),
      child: MaterialApp(
        title: 'Barber App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            surface: Color(0xFF1C1C2E),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        ),
        // AuthWrapper decide automáticamente si mostrar Login o Home.
        home: const AuthWrapper(),
      ),
    );
  }
}
