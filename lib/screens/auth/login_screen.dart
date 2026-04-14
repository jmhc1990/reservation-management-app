import 'package:flutter/material.dart';
import 'register_screen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Barbería Zaitec'),
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 40),
            TextField(
              style: TextStyle(color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: Color(0xFF1A1A1A)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              style: TextStyle(color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Color(0xFF1A1A1A)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(height: 30),
           ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('ENTRAR', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                '¿No tienes cuenta? Regístrate aquí',
                style: TextStyle(color:Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}