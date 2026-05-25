import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

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
            const SizedBox(height: 20),

            Divider(color: primaryGold, thickness: 4),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'SERVICIOS',
                style: GoogleFonts.oswald(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: darkTextColor,
                ),
              ),
            ),

            Divider(color: primaryGold, thickness: 4),

            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildServiceItem(
                    title: 'CORTE DE PELO',
                    price: '15€',
                    description: 'Corte clásico o moderno a tu gusto.',
                  ),
                  _buildServiceItem(
                    title: 'ARREGLO DE BARBA',
                    price: '10€',
                    description: 'Perfilado y recorte con hidratación.',
                  ),
                  _buildServiceItem(
                    title: 'CORTE + BARBA',
                    price: '22€',
                    description: 'Combo completo para un look perfecto.',
                  ),
                  _buildServiceItem(
                    title: 'AFEITADO CLÁSICO',
                    price: '12€',
                    description: 'Afeitado tradicional con toalla caliente.',
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                width: 241, 
                height: 50,
                decoration: BoxDecoration(
                  color: primaryGold,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'RESERVAR CITA',
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

  Widget _buildServiceItem({required String title, required String price, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primaryGold.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.oswald(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: darkTextColor,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryGold,
            ),
          ),
        ],
      ),
    );
  }
}