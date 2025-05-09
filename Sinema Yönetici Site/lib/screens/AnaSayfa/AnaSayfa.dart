import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sinema Yönetim Sistemine Hoşgeldin',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }
}