import 'package:flutter/material.dart';

class UlasimPage extends StatelessWidget {
  const UlasimPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Ulaşım', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/ulasim_harita.png', // Yerel varlık yolu
                    height: 600, // Yüksekliği iki katına çıkarıldı
                    width: double.infinity, // Genişliği tam ekran yap
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Adres',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yıldız Mahallesi, Şerefli Veli Sokak, Yıldız AVM, No:4, Kat:3, Beşiktaş/İstanbul',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Toplu Taşıma ile Ulaşım',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Metro: M2 hattı ile Gayrettepe durağında inip 10 dakika yürüyebilirsiniz.\n- Otobüs: 43, 129T, 58A numaralı otobüslerle Yıldız durağında inebilirsiniz.\n- Dolmuş: Beşiktaş-Yıldız hattı dolmuşları ile kolayca ulaşabilirsiniz.',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 24),
              const Text(
                'Yürüyerek Ulaşım',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Beşiktaş merkezden Yıldız Alışveriş Merkezi\'ne yürüyerek yaklaşık 15 dakikada ulaşabilirsiniz.',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Daha fazla bilgi için: info@yildizsinemalar.com',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}