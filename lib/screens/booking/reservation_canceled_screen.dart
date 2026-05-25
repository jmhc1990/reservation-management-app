import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservaCancelada extends StatelessWidget {
  final String barbero;
  final String servicio;
  final String fecha;
  final String hora;

  const ReservaCancelada({
    super.key,
    required this.barbero,
    required this.servicio,
    required this.fecha,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final errorColor = const Color(0xFFBA1A1A);
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
                  color: errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined, color: errorColor, size: 80),
              ),

              const SizedBox(height: 30),

              Text(
                'Reserva Cancelada',
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Parece que ha habido un problema o has decidido cancelar el proceso. No se ha realizado ningún cargo.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'REINTENTAR RESERVA',
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: BorderSide(color: goldColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'VOLVER AL INICIO',
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    color: goldColor,
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
}
