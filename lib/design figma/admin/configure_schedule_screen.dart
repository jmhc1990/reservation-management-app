import 'package:flutter/material.dart';

class ConfigurarHorarioScreen extends StatefulWidget {
  const ConfigurarHorarioScreen({super.key});

  @override
  State<ConfigurarHorarioScreen> createState() => _ConfigurarHorarioScreenState();
}

class _ConfigurarHorarioScreenState extends State<ConfigurarHorarioScreen> {

  Map<String, bool> diasActivos = {
    'Lunes': true, 'Martes': true, 'Miércoles': true,
    'Jueves': true, 'Viernes': true, 'Sábado': true, 'Domingo': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONFIGURAR HORARIO',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(height: 4, color: const Color(0xFF8B6B4E)), 
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: diasActivos.keys.map((dia) {
                return _buildDiaRow(dia);
              }).toList(),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
              
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'GUARDAR HORARIO',
                style: TextStyle(color: Colors.white, fontFamily: 'Oswald', fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaRow(String dia) {
    bool estaActivo = diasActivos[dia]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dia,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Switch(
                value: estaActivo,
                activeThumbColor: const Color(0xFF8B6B4E),
                onChanged: (value) {
                  setState(() {
                    diasActivos[dia] = value;
                  });
                },
              ),
            ],
          ),
          if (estaActivo)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TimeBox(label: 'Inicio', hora: '09:00'),
                  Icon(Icons.remove, color: Colors.grey),
                  _TimeBox(label: 'Fin', hora: '20:00'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String hora;
  const _TimeBox({required this.label, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Container(
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Text(
            hora,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B6B4E)),
          ),
        ),
      ],
    );
  }
}