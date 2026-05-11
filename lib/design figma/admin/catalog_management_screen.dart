import 'package:flutter/material.dart';

class GestionCatalogoScreen extends StatelessWidget {
  const GestionCatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: const Text(
          'GESTIÓN DE CATÁLOGO',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          
          Container(height: 4, color: const Color(0xFFD4AF37)),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                _buildServiceItem(
                  titulo: 'Corte Signature',
                  descripcion: 'Asesoramiento, corte a tijera y lavado premium.',
                  precio: '30€',
                ),
                const SizedBox(height: 16),
                
                _buildServiceItem(
                  titulo: 'Arreglo de Barba',
                  descripcion: 'Perfilado con navaja e hidratación.',
                  precio: '15€',
                ),
              ],
            ),
          ),

         
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'AÑADIR NUEVO SERVICIO',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Oswald',
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildServiceItem({required String titulo, required String descripcion, required String precio}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1), // Borde dorado [cite: 829]
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Oswald',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            precio,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.edit, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}