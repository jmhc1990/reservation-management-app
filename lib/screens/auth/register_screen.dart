import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:style_sync/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    final success = await context.read<AuthController>().register(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
        );

    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final errorMessage = context.watch<AuthController>().errorMessage;

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
              controller: _nameController,
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
            // Nuevo campo: email
            TextField(
              controller: _emailController,
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

            // Nuevo campo: contraseña
            TextField(
              controller: _passwordController,
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

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'Teléfono',
                labelStyle: GoogleFonts.lato(color: const Color(0xFF1A1A1A)),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF1A1A1A)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            if (errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  errorMessage,
                  style: GoogleFonts.lato(color: Colors.red),
                ),
              ),
            ],

            ElevatedButton(
              onPressed: isLoading ? null : () => _handleRegister(context),
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
