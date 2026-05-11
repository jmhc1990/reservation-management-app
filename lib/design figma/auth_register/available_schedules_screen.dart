import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAvailableSlotsScreen extends StatefulWidget {
  const MyAvailableSlotsScreen({super.key});

  @override
  State<MyAvailableSlotsScreen> createState() => _MyAvailableSlotsScreenState();
}

class _MyAvailableSlotsScreenState extends State<MyAvailableSlotsScreen> {
  // Colores de tu diseño
  final Color primaryGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFFDFBF7);
  
  String? selectedHour; 
  
  final List<String> hours = [
    '09:00', '10:00', '11:00', '12:00', 
    '13:00', '16:00', '17:00', '18:00', 
    '19:00', '20:00'
  ];

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
                'HORARIOS DISPONIBLES',
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            Divider(color: primaryGold, thickness: 4),

            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona el día:',
                    style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryGold),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Lunes, 15 de Mayo"),
                        Icon(Icons.calendar_today, color: primaryGold),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 botones por fila
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.1, 
                  ),
                  itemCount: hours.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedHour == hours[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedHour = hours[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? primaryGold : Colors.white,
                          border: Border.all(color: primaryGold, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            hours[index],
                            style: GoogleFonts.oswald(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: 241, 
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedHour == null ? null : () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CONFIRMAR CITA',
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