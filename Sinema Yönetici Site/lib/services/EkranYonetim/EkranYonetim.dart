import 'package:flutter/material.dart';

import '../../screens/AnaSayfa/AnaSayfa.dart';
import '../../screens/FilmEkle/FilmEkle.dart';
import '../../screens/Puanlama/Puanlama.dart';
import '../../screens/SalonBilgi/SalonBilgi.dart';
import '../../screens/SeansYonetim/SeansYonetim.dart';
import '../../screens/StokYonetim/StokYonetim.dart';

class SayfaYonetim extends StatefulWidget {
  @override
  _SayfaYonetimState createState() => _SayfaYonetimState();
}
class _SayfaYonetimState extends State<SayfaYonetim> {
  int _currentIndex = 2;

  IconData _getIcon(int index) {
    // Indices shifted after removing SeyirciEkleme (original index 0)
    switch(index) {
      case 0: return Icons.movie; // Was 1
      case 1: return Icons.link; // Was 2
    // Index 2 is HomePage, not shown in drawer menu items loop
      case 3: return Icons.info; // Was 4
      case 4: return Icons.inventory; // Was 5
      case 5: return Icons.star; // Was 6
      default: return Icons.error;
    }
  }

  final List<Widget> _pages = [
    FilmEklemePage(),
    SessionPage(),
    HomePage(),
    SalonBilgiPage(),
    StokYonetimPage(),
    FilmPuanlariPage(),
  ];

  final List<String> _titles = [
    'Film Ekleme',
    'Seans Yönetimi',
    'Ana Sayfa',
    'Salon Bilgi',
    'Stok Yönetimi',
    'Film Puanları',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(_titles[_currentIndex], style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      body: _pages[_currentIndex],
      drawer: Drawer(
        backgroundColor: Colors.grey[700],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            // HomePage (index 2) is excluded from this list
            ..._pages.asMap().entries.where((e) => e.key != 2).map((entry) => Column(
              children: [
                ListTile(
                  // Use the updated _getIcon logic which handles the index shift
                  trailing: Icon(_getIcon(entry.key), color: Colors.white),
                  title: Text(_titles[entry.key], style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                  onTap: () {
                    setState(() {
                      _currentIndex = entry.key;
                    });
                    Navigator.pop(context);
                  },
                ),
                Divider(color: Colors.black, height: 1),
              ],
            )).toList(),
            Column(
              children: [
                Divider(color: Colors.grey[300], height: 1),
                ListTile(
                  trailing: Icon(Icons.arrow_forward, color: Colors.white),
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Ana Sayfaya Dön', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                  onTap: () {
                    setState(() {
                      // HomePage is now at index 2
                      _currentIndex = 2;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}