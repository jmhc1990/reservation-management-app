import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBookingConfirmedScreen extends StatelessWidget {
  const MyBookingConfirmedScreen({super.key});


  final Color primaryGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFFDFBF7);
  final Color darkTextColor = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            Divider(color: primaryGold, thickness: 4),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '¡RESERVA\nCONFIRMADA!',
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 30),
            
            
            Icon(Icons.check_circle_outline, size: 100, color: primaryGold),

            const SizedBox(height: 30),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: primaryGold, width: 5),
                ),
                child: Column(
                  children: [
                   
                    Text(
                      'Corte Signature',
                      style: GoogleFonts.oswald(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Fecha y Hora [cite: 1706]
                    Text(
                      'MARTES, 2 ABRIL, 12:30',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                   
                    Text(
                      'Barbero - David',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: primaryGold, thickness: 2), 
                    const SizedBox(height: 10),
                    // Total [cite: 1803]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '30€',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),


            Padding(
              padding: const EdgeInsets.all(30),
              child: SizedBox(
                width: 241,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'VOLVER AL INICIO',
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
    );
  }
}