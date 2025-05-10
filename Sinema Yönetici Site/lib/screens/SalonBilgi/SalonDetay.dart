import 'package:flutter/material.dart';

class SalonDetayPage extends StatelessWidget {
  final int salonNo;

  SalonDetayPage({required this.salonNo});

  @override
  Widget build(BuildContext context) {
    final gunler = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Salon $salonNo'),
      ),
      body: Column(
        children: gunler.map((gun) =>
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[900]!, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(gun, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ).toList(),
      ),
    );
  }
}

