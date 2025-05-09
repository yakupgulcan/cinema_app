import 'package:flutter/material.dart';
import 'package:sinema_yonetim_sistemi/models/CinemaHall.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/CinemaHall.dart';
import 'package:sinema_yonetim_sistemi/widgets/Loading.dart';

// Renk Tanımlamaları (Puanlama sayfasıyla aynı)
const Color primaryColor = Color(0xFF607D8B); // Mavi Gri
const Color accentColor = Color(0xFF03A9F4); // Açık Mavi
const Color backgroundColor = Color(0xFFECEFF1); // Çok Açık Gri
const Color textColorPrimary = Colors.black87;
const Color textColorSecondary = Colors.black54;

class SalonBilgiPage extends StatefulWidget {
  @override
  State<SalonBilgiPage> createState() => _SalonBilgiPageState();
}

class _SalonBilgiPageState extends State<SalonBilgiPage> {
  // Örnek salon verileri
  List<Hall> salonlar = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Loadingscreen(
        task: ()async{
          salonlar = await getCinemaHalls()??[];
          setState(() {});
        },
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            _buildSectionTitle(context, 'Salon Bilgileri'),
            _buildSalonList(context, salonlar),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColorPrimary),
      ),
    );
  }

  Widget _buildSalonList(BuildContext context, List<Hall> salonlar) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: salonlar.map((salon) {
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(salon.hallName!, style: TextStyle(fontSize: 16, color: textColorPrimary, fontWeight: FontWeight.w500)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('Koltuk Sayısı: ${salon.capacity!}', style: TextStyle(fontSize: 14, color: textColorSecondary)),
                      SizedBox(height: 8),
                      Text('2D: Evet | 3D: ${salon.hallType! == '3D' ? 'Evet' : 'Hayır'}',
                          style: TextStyle(fontSize: 14, color: textColorSecondary)),
                    ],
                  ),
                ),
                Divider(height: 2, thickness: 2, color: Colors.grey[500]),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}