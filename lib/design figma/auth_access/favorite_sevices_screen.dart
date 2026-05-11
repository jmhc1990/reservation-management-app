import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MisFavoritos extends StatelessWidget {
  const MisFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final bgColor = const Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                  label: Text('Atrás', style: GoogleFonts.oswald(color: Colors.black, fontSize: 24)),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Tus Servicios Favoritos',
                  style: GoogleFonts.oswald(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),

              Container(height: 4, color: goldColor),

              const SizedBox(height: 30),

              _buildTarjetaServicio(
                context, 
                titulo: 'Corte Signature', 
                subtitulo: 'Asesoramiento, corte a tijera y lavado premium. 60 min.',
                goldColor: goldColor,
              ),

              const SizedBox(height: 40),

              _buildTarjetaFidelizacion(goldColor),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTarjetaServicio(BuildContext context, {required String titulo, required String subtitulo, required Color goldColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitulo, style: GoogleFonts.lato(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('REPETIR EXPERIENCIA', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildTarjetaFidelizacion(Color goldColor) {
    return Center(
      child: Column(
        children: [
          Text('Tarjeta de Fidelización', style: GoogleFonts.oswald(fontSize: 20)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: goldColor, size: 40),
              Icon(Icons.star, color: goldColor, size: 40),
              Icon(Icons.star_border, color: goldColor, size: 40),
            ],
          ),
        ],
      ),
    );
  }
}