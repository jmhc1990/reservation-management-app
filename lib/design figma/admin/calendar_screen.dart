import 'package:flutter/material.dart';

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

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
          'CALENDARIO',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mayo 2024',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
                    ],
                  ),
                ],
              ),
            ),
            
           
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DiaSemanaTexto('L'), _DiaSemanaTexto('M'), _DiaSemanaTexto('X'),
                  _DiaSemanaTexto('J'), _DiaSemanaTexto('V'), _DiaSemanaTexto('S'), _DiaSemanaTexto('D'),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  int dia = index + 1;
                  
                  bool esHoy = (dia == 15); 
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: esHoy ? const Color(0xFF8B6B4E) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        '$dia',
                        style: TextStyle(
                          color: esHoy ? Colors.white : Colors.black,
                          fontWeight: esHoy ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Vacaciones',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.beach_access, color: Color(0xFF8B6B4E)),
                    title: Text('Solicitar días libres'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaSemanaTexto extends StatelessWidget {
  final String texto;
  const _DiaSemanaTexto(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }
}