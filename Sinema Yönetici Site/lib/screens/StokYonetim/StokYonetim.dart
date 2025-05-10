import 'package:flutter/material.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/Stok.dart';
import 'package:sinema_yonetim_sistemi/widgets/Loading.dart';

class StokYonetimPage extends StatefulWidget {
  @override
  _StokYonetimPageState createState() => _StokYonetimPageState();
}

class _StokYonetimPageState extends State<StokYonetimPage> {
  // Stok kategorileri ve Kategori bazlı ürünler kaldırıldı

  // Yeni ürün listesi
  List<Map<String, dynamic>> urunlerListesi = [
    {'isim': 'Patlamış Mısır', 'eldekalan': 100, 'maksimum': 200, 'icon': Icons.local_dining},
    {'isim': 'Gözlük', 'eldekalan': 50, 'maksimum': 100, 'icon': Icons.threed_rotation}, // 3D Gözlük için bir ikon
    {'isim': 'Kola', 'eldekalan': 70, 'maksimum': 150, 'icon': Icons.local_drink_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Arka plan beyaz yapıldı
      appBar: AppBar(
        title: Text('ÜRÜNLER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün kartları grid'i
            Loadingscreen(
              task: () async{
                urunlerListesi[0]['eldekalan'] = await getConcessionsQuantity("Patlamış Mısır");
                urunlerListesi[2]['eldekalan'] = await getConcessionsQuantity("Kola");
                urunlerListesi[1]['eldekalan'] = await getConcessionsQuantity("Gözlük");
                setState(() {
                });
              },
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 ürün yan yana
                  childAspectRatio: 0.9, // Kartların en boy oranı ayarlandı
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: urunlerListesi.length,
                itemBuilder: (context, index) {
                  final urun = urunlerListesi[index];
                  return _buildUrunCard(urun);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildKategoriSection metodu kaldırıldı
  Widget _buildKategoriSection(String kategori) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori başlığı ve Ürünler başlığı tek satırda
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800], // Kategori başlığı için biraz daha açık bir ton
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kategori,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.0),
        // Ürün kartları grid'i
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: urunlerListesi.length,
          itemBuilder: (context, index) {
            final urun = urunlerListesi[index];
            return urun != null ? _buildUrunCard(urun) : SizedBox.shrink();
          },
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildUrunCard(Map<String, dynamic> urun) {
    // Stok durumuna göre renk belirleme
    final double stokOrani = urun['eldekalan'] / urun['maksimum'];
    Color stokRengi;

    if (stokOrani < 0.3) {
      stokRengi = Colors.red[400]!;
    } else if (stokOrani < 0.7) {
      stokRengi = Colors.orange[300]!;
    } else {
      stokRengi = Colors.green[400]!;
    }

    // Satılan ürün miktarı için controller kaldırıldı

    return Card(
      elevation: 4.0, // Gölge biraz artırıldı
      color: Colors.white,
      shadowColor: Colors.blueGrey[200], // Gölge rengi yumuşatıldı
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Kenarlar daha yuvarlak
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // İçerik ortalandı
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ürün ikonu
            Icon(urun['icon'] as IconData?, size: 48.0, color: Colors.blueGrey[700]),
            SizedBox(height: 8.0),
            // Ürün adı
            Text(
              urun['isim'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            // Stok bilgileri
            Column(
              children: [
                Text('STOK:', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.black54)),
                Text(
                  '${urun['eldekalan']}/${urun['maksimum']}',
                  style: TextStyle(color: stokRengi, fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ],
            ),
            // Stok durumu göstergesi
            LinearProgressIndicator(
              value: stokOrani,
              backgroundColor: Colors.blueGrey[100],
              valueColor: AlwaysStoppedAnimation<Color>(stokRengi),
              minHeight: 6,
            ),
            SizedBox(height: 10.0),
            // Satılan ürün girişi ve Ekleme butonu kaldırıldı
            // Yenileme butonu
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, size: 18.0),
              label: Text('Yenile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: TextStyle(fontSize: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async{
                await updateConcessionsQuantity(urun['isim'], urun['maksimum']);
                int newQuantity = await getConcessionsQuantity(urun['isim']) ?? 0;
                setState(() {
                  urun['eldekalan'] = newQuantity;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}