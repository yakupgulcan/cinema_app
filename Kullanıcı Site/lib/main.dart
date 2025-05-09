import 'package:flutter/material.dart' hide CarouselController;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/AnaSayfa/AnaSayfa.dart';
import 'package:cinema_app/providers/userProvider.dart';

void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CustomerProvider()),
          ],
          child: const CinemaApp()
      )
  );
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

