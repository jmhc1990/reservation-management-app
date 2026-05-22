import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HorariosDisponibles extends StatelessWidget {
  const HorariosDisponibles({super.key});

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final bgColor = const Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
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
                    'Selección de hora',
                    style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Jueves, 15 de Mayo',
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(width: 60, height: 3, color: goldColor),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                crossAxisCount: 3, // 3 botones por fila
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 2.2, // Para que los botones sean alargados
                children: [
                  _buildHoraBtn('09:00', goldColor, true), // Disponible
                  _buildHoraBtn('10:00', goldColor, true),
                  _buildHoraBtn('11:00', goldColor, false), // Ocupado
                  _buildHoraBtn('12:00', goldColor, true),
                  _buildHoraBtn('13:00', goldColor, true),
                  _buildHoraBtn('16:00', goldColor, true),
                  _buildHoraBtn('17:00', goldColor, true),
                  _buildHoraBtn('18:00', goldColor, true),
                  _buildHoraBtn('19:00', goldColor, true),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'CONFIRMAR CITA',
                  style: GoogleFonts.oswald(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoraBtn(String hora, Color gold, bool disponible) {
    return Container(
      decoration: BoxDecoration(
        color: disponible ? Colors.white : Colors.grey.withValues(alpha: 0.2),
        border: Border.all(color: disponible ? gold : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          hora,
          style: GoogleFonts.lato(
            color: disponible ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}