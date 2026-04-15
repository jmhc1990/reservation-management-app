import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text(
          'Crear cuenta',
          style: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Únete a la Barbería',
              style: GoogleFonts.oswald(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 40),

            // Nuevo campo: Nombre
            TextField(
              style: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                labelStyle: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
                prefixIcon: Icon(Icons.person, color: Color(0xFF1A1A1A)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              style: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
                prefixIcon: Icon(Icons.email, color: Color(0xFF1A1A1A)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1), // Aquí está el gris
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              obscureText: true,
              style: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF1A1A1A)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1), // Aquí está el gris
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD4AF37),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                'REGISTRARSE',
                style: GoogleFonts.oswald(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
