import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EligeExperto extends StatelessWidget {
  const EligeExperto({super.key});

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final bgColor = const Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    'Elige a tu experto',
                    style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 55),
              child: Text(
                'Nuestros maestros barberos',
                style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
              ),
            ),
            
            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildExpertoCard('Alejandro García', 'Especialista en degradados', goldColor),
                  _buildExpertoCard('Roberto Sanz', 'Maestro barbero y afeitado clásico', goldColor),
                  _buildExpertoCard('Cualquier experto', 'El primero que esté disponible', goldColor, esAleatorio: true),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertoCard(String nombre, String especialidad, Color gold, {bool esAleatorio = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esAleatorio ? gold : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(esAleatorio ? Icons.shuffle : Icons.person, color: gold, size: 30),
          ),
          const SizedBox(width: 20),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: GoogleFonts.oswald(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(especialidad, style: GoogleFonts.lato(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: gold, size: 16),
        ],
      ),
    );
  }
}