import 'package:flutter/material.dart';
import 'dart:io' if (dart.library.html) 'dart:html'; // Koşullu import
import 'services/EkranYonetim/EkranYonetim.dart';
import 'package:sinema_yonetim_sistemi/constants/globals.dart';
import 'dart:html' as html;

void main() {
  serverAddress = html.window.location.origin;
  runApp(SinemaYonetimSistemi());
}

class SinemaYonetimSistemi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinema Yönetim Sistemi',
      theme: theme,
      home: SayfaYonetim(),
    );
  }
}

ThemeData theme = ThemeData(
  scaffoldBackgroundColor: Colors.grey[100],
  appBarTheme: AppBarTheme(backgroundColor: Colors.black54, titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), iconTheme: IconThemeData(color: Colors.white))
);



// Her sekme için basit placeholder sayfalar:












