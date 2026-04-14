import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor:Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Únete a la Barbería',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 40),
            
            // Nuevo campo: Nombre
            TextField(
              style: TextStyle(color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                labelStyle: TextStyle(color: Color(0xFF1A1A1A)),
                border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.person, color: Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(height: 20),

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
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('REGISTRARSE', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}