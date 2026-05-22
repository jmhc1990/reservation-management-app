import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyExperiencesScreen extends StatelessWidget {
  const MyExperiencesScreen({super.key});

  final Color primaryGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFFDFBF7);
  final Color cardGrey = const Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Divider(color: primaryGold, thickness: 4),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [

                  Text(
                    'TUS EXPERIENCIAS',
                    style: GoogleFonts.oswald(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    'Elige a tu experto',
                    style: GoogleFonts.oswald(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: primaryGold, thickness: 4), 

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // BARBERO 1: DAVID 
                  _buildExpertCard(
                    name: 'David',
                    description: 'Especialista en degradados y corte a tijera.', // [cite: 659]
                    opacity: 0.50, 
                  ),
                  const SizedBox(height: 20),
                  
                  _buildExpertCard(
                    name: 'Pedro',
                    description: 'Barbero Senior', 
                    opacity: 0.67, 
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'CONTINUAR',
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

  Widget _buildExpertCard({required String name, required String description, required double opacity}) {
    return Container(
      width: double.infinity,
      height: 131, // Altura de tu Figma [cite: 593]
      decoration: BoxDecoration(
        color: cardGrey.withOpacity(opacity),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryGold, width: 5), // Borde dorado [cite: 599]
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryGold, width: 4),
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.oswald(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}