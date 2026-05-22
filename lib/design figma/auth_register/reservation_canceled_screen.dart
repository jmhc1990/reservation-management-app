import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBookingCancelledScreen extends StatelessWidget {
  const MyBookingCancelledScreen({super.key});

  
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
            
            const SizedBox(height: 40),
            
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '¡RESERVA\nCANCELADA!',
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 50),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: primaryGold, width: 5),
                ),
                child: Column(
                  children: [
                    // Icono de aviso/error
                    Icon(Icons.error_outline, size: 80, color: primaryGold),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Lo sentimos, no hemos podido confirmar tu cita.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

           
            Padding(
              padding: const EdgeInsets.all(30),
              child: Container(
                width: 241,
                height: 50,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'INTENTAR DE NUEVO',
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