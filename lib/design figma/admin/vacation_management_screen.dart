import 'package:flutter/material.dart';

class GestionVacacionesScreen extends StatelessWidget {
  const GestionVacacionesScreen({super.key});

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
          'MIS VACACIONES',
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
          
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B6B4E), 
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Column(
              children: [
                Text(
                  'Días Disponibles',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  '12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                  ),
                ),
                Text(
                  'Periodo 2024',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Solicitudes Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildVacationRequest(
                  fecha: '15 Ago - 22 Ago',
                  estado: 'Aprobado',
                  colorEstado: Colors.green,
                  dias: 7,
                ),
                _buildVacationRequest(
                  fecha: '10 Dic - 15 Dic',
                  estado: 'Pendiente',
                  colorEstado: Colors.orange,
                  dias: 5,
                ),
              ],
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'SOLICITAR VACACIONES',
                style: TextStyle(color: Colors.white, fontFamily: 'Oswald'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                minimumSize: const Size(double.infinity, 55),
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

  
  Widget _buildVacationRequest({
    required String fecha,
    required String estado,
    required Color colorEstado,
    required int dias,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fecha,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('$dias días solicitados', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              estado,
              style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}