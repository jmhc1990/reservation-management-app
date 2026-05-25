import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservaConfirmada extends StatelessWidget {
  const ReservaConfirmada({super.key});

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final bgColor = const Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline, color: goldColor, size: 80),
              ),
              
              const SizedBox(height: 30),

              Text(
                '¡Reserva Confirmada!',
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Tu cita ha sido programada con éxito. Te hemos enviado un correo con los detalles.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    _buildResumenRow(Icons.calendar_today, 'Día', '15 de Mayo, 2024'),
                    const Divider(height: 30),
                    _buildResumenRow(Icons.access_time, 'Hora', '17:00 PM'),
                    const Divider(height: 30),
                    _buildResumenRow(Icons.person_outline, 'Barbero', 'Alejandro García'),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: () {
                  // Aquí volveríamos a la pantalla principal
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'VOLVER AL INICIO',
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 15),
        Text(
          '$label:',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}