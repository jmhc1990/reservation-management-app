import 'package:flutter/material.dart';

class GestionBarberosScreen extends StatelessWidget {
  const GestionBarberosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EQUIPO / BARBEROS',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Línea decorativa dorada
          Container(height: 4, color: const Color(0xFFD4AF37)),
          
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Administra el personal y sus turnos de trabajo.',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Inter'),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildBarberCard(
                  nombre: 'Carlos Jiménez',
                  especialidad: 'Especialista en Degradados',
                  urlImagen: 'https://via.placeholder.com/150', 
                ),
                const SizedBox(height: 15),
                _buildBarberCard(
                  nombre: 'Mario Rossi',
                  especialidad: 'Experto en Barba y Navaja',
                  urlImagen: 'https://via.placeholder.com/150',
                ),
                const SizedBox(height: 15),
                _buildBarberCard(
                  nombre: 'Elena Sanz',
                  especialidad: 'Corte Clásico y Tijera',
                  urlImagen: 'https://via.placeholder.com/150',
                ),
              ],
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF8B6B4E)),
              label: const Text(
                'AÑADIR BARBERO',
                style: TextStyle(
                  color: Color(0xFF8B6B4E),
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8B6B4E), width: 2),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarberCard({required String nombre, required String especialidad, required String urlImagen}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFD4AF37),
            backgroundImage: NetworkImage(urlImagen),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  especialidad,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF8B6B4E)),
            onPressed: () {
             
            },
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}