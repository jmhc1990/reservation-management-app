import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyRegisterScreen extends StatefulWidget {
  const MyRegisterScreen({super.key});

  @override
  State<MyRegisterScreen> createState() => _MyRegisterScreenState();
}

class _MyRegisterScreenState extends State<MyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final Color primaryGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFFDFBF7);
  final Color darkTextColor = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Fondo de tu Figma [cite: 11]
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 68), // Margen superior de Figma [cite: 16]
                
                Text(
                  'Únete a la Barbería',
                  style: GoogleFonts.oswald(
                    color: darkTextColor,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: 40),

                _buildCustomTextField(
                  label: 'Nombre completo',
                  icon: Icons.person_outline,
                ),
                
                const SizedBox(height: 20),

                _buildCustomTextField(
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                ),
                
                const SizedBox(height: 20),

                _buildCustomTextField(
                  label: 'Número de teléfono',
                  icon: Icons.phone_android_outlined,
                ),

                const SizedBox(height: 60),

                Center(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'REGISTRARSE',
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            color: darkTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryGold),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryGold, width: 2), // Líneas de tu Figma [cite: 84, 86]
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryGold, width: 4),
            ),
          ),
        ),
      ],
    );
  }
}