import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinema_yonetim_sistemi/models/CinemaHall.dart';
import 'package:sinema_yonetim_sistemi/models/Movie.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/CinemaHall.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/FileUpload.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/MovieCreate.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/GetMovies.dart';
import 'package:sinema_yonetim_sistemi/widgets/Loading.dart';

class FilmEklemePage extends StatefulWidget { // StatelessWidget'tan StatefulWidget'a dönüştür
  @override
  _FilmEklemePageState createState() => _FilmEklemePageState();
}

class _FilmEklemePageState extends State<FilmEklemePage> { // State sınıfını oluştur
  final _isimController = TextEditingController();
  final _turController = TextEditingController();
  final _genreController = TextEditingController();
  final _yonetmenController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _sureController = TextEditingController();
  // final _fragmanLinkController = TextEditingController();
  XFile? _secilenResim;
  Uint8List? _secilenResimBytes; // Web için resim verisi

  static List<Movie> _eklenenFilmler = []; // Eklenen filmleri tutacak statik liste
  final ImagePicker _picker = ImagePicker();
  bool _formDolu = false;
  final Map<int, bool> _silmeModuAktif = {};

  @override
  void initState() {
    super.initState();
    _getMovies();
  }

  @override
  void dispose() {
    _isimController.dispose();
    _turController.dispose();
    _sureController.dispose();
    _yonetmenController.dispose();
    _genreController.dispose();
    _aciklamaController.dispose();
    // _fragmanLinkController.dispose();
    super.dispose();
  }

  void _getMovies() async{
    _eklenenFilmler = await getMovies(null) ?? [];
    setState(() {
    });
  }

  void _formDurumunuGuncelle() {
    setState(() {
      _formDolu = _isimController.text.isNotEmpty &&
          _turController.text.isNotEmpty &&
          _sureController.text.isNotEmpty &&
          _yonetmenController.text.isNotEmpty &&
          _genreController.text.isNotEmpty &&
          // _fragmanLinkController.text.isNotEmpty &&
          _secilenResimBytes != null;
    });
  }

  Future<void> _resimSec() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) { // Kullanıcı resim seçtiyse
      final bytes = await image.readAsBytes();
      setState(() {
        _secilenResim = image;
        _secilenResimBytes = bytes;
        _formDurumunuGuncelle(); // Resim seçildikten sonra form durumunu güncelle
      });
    }
  }

  void _filmEkle() async{
    if (_formDolu && _secilenResimBytes != null) {
      int? id = await uploadMovie(
          movieName: _isimController.text,
          duration: int.parse(_sureController.text),
          movieGenre: _genreController.text,
          movieType: _turController.text,
          description: _aciklamaController.text,
          director: _yonetmenController.text,
          // trailerUrl: _fragmanLinkController.text,
      );
      if(id != null)
        await uploadFile(context, _secilenResimBytes, id);
      setState(() {
        // _eklenenFilmler.add({});
        // Formu temizle
        _isimController.clear();
        _turController.clear();
        _sureController.clear();
        _yonetmenController.clear();
        _genreController.clear();
        _aciklamaController.clear();
        // _fragmanLinkController.clear();
        _secilenResim = null;
        _secilenResimBytes = null;
        _formDolu = false; // Ekleme sonrası butonu pasif yap
        _silmeModuAktif.clear(); // Silme modunu sıfırla
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width*0.3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Yeni Film Ekle", style: TextStyle(fontSize: 30,),),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: _resimSec, // Resim seçme fonksiyonunu çağır
                    child: Container(
                      height: 200,
                      width: double.infinity, // Genişliği doldur
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[900]!, width: 1.5), // Çerçeve eklendi
                        borderRadius: BorderRadius.circular(10),
                        image: _secilenResimBytes != null
                            ? DecorationImage(
                          image: MemoryImage(_secilenResimBytes!), // Seçilen resmi göster
                          fit: BoxFit.contain, // Resmi sığdır, kenarları kesme
                        )
                            : null, // Resim yoksa arkaplan resmi olmasın
                      ),
                      child: _secilenResimBytes == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey[600]), // İkon güncellendi
                          SizedBox(height: 8),
                          Text('Film Afişi Ekle', style: TextStyle(color: Colors.grey[700])), // Metin güncellendi
                        ],
                      )
                          : null, // Resim varsa ikon/metin gösterme
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _isimController,
                    decoration: InputDecoration(
                      labelText: 'Film İsmi',
                      hintText: 'Film adını giriniz',
                      border: OutlineInputBorder(), // Kenarlık stili değiştirildi
                    ),
                  ),
                  SizedBox(height: 10), // Alanlar arasına boşluk eklendi
                  TextFormField(
                    controller: _aciklamaController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      hintText: 'Film açıklaması giriniz',
                      border: OutlineInputBorder(), // Kenarlık stili değiştirildi
                    ),
                  ),
                  SizedBox(height: 10), // Alanlar arasına boşluk eklendi
                  TextFormField(
                    controller: _yonetmenController,
                    decoration: InputDecoration(
                      labelText: 'Yönetmen',
                      hintText: 'Yönetmen ismini giriniz',
                      border: OutlineInputBorder(), // Kenarlık stili değiştirildi
                    ),
                  ),
                  SizedBox(height: 10), // Alanlar arasına boşluk eklendi
                  TextFormField(
                    controller: _genreController,
                    decoration: InputDecoration(
                      labelText: 'Türü',
                      hintText: 'Film türünü giriniz',
                      border: OutlineInputBorder(), // Kenarlık stili değiştirildi
                    ),
                  ),
                  SizedBox(height: 10), // Alanlar arasına boşluk eklendi
                  TextFormField(
                    controller: _turController,
                    decoration: InputDecoration(
                      labelText: 'Yapısı',
                      hintText: 'Film yapısını giriniz (2D-3D)',
                      border: OutlineInputBorder(), // Kenarlık stili değiştirildi
                    ),
                  ),
                  SizedBox(height: 10), // Alanlar arasına boşluk eklendi
                  TextFormField(
                    controller: _sureController,
                    keyboardType: TextInputType.number, // Sayısal klavye
                    decoration: InputDecoration(
                      labelText: 'Süre (dk)',
                      hintText: 'Film süresini dakika olarak giriniz',
                      border: OutlineInputBorder(), // Kenarlık stili değiştirildi
                    ),
                  ),
                  // SizedBox(height: 10), // Alanlar arasına boşluk eklendi
                  // TextFormField(
                  //   controller: _fragmanLinkController,
                  //   decoration: InputDecoration(
                  //     labelText: 'Fragman Linki',
                  //     hintText: 'Film fragman linkini giriniz (YouTube vb.)',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   onChanged: (_) => _formDurumunuGuncelle(),
                  // ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _formDolu ? _filmEkle : null, // Form doluysa aktif, değilse pasif
                    icon: Icon(Icons.add_circle_outline),
                    label: Text('Film Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _formDolu ? Colors.blue[900] : Colors.grey, // Duruma göre renk
                      foregroundColor: Colors.white, // Buton yazı rengi
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Buton boyutu
                      textStyle: TextStyle(fontSize: 16), // Yazı boyutu
                    ),
                  ),
                  SizedBox(height: 30),
                  // Eklenen filmleri gösteren GridView
                ],
              ),
            ),
          ),
          if (_eklenenFilmler.isNotEmpty)
            SizedBox(
              width: MediaQuery.sizeOf(context).width*0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Envanterdeki Filmler", style: TextStyle(fontSize: 30,),),
                    SizedBox(height: 20,),
                    GridView.builder(
                      shrinkWrap: true, // İçeriğe göre boyutlan
                      physics: NeverScrollableScrollPhysics(), // Ana kaydırmayı engelleme
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Satır başına 6 film gösterilecek
                        crossAxisSpacing: 10, // Yatay boşluk (küçültüldü)
                        mainAxisSpacing: 10, // Dikey boşluk (küçültüldü)
                        childAspectRatio: 1 / 1.48, // En boy oranı (boy, enin yaklaşık 1.48 katı)
                      ),
                      itemCount: _eklenenFilmler.length,
                      itemBuilder: (context, index) {
                        final film = _eklenenFilmler[index];
                        return Stack(
                          children: [
                            Card( // Daha belirgin görünüm için Card widget'ı
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias, // Resmin Card sınırlarını aşmasını engelle
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch, // İçeriği genişlet
                                children: [
                                  Expanded(
                                      child: Image.network(
                                        "http://127.0.0.1:5000/images/${film.movieID}", // Uint8List verisi kullanımı
                                        fit: BoxFit.cover, // Resmi kapla
                                        errorBuilder: (context, error, stackTrace) {
                                          // Resim yüklenemezse placeholder göster
                                          return Container(
                                            color: Colors.grey[300],
                                            child: Icon(Icons.broken_image, color: Colors.grey[600]),
                                          );
                                        },
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      film.movieName,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis, // Taşarsa ... ile bitir
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Sağ üst köşeye silme butonu ekle
                            Positioned(
                              top:5,
                              right:5,
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _silmeModuAktif[index] = true),
                                onExit: (_) => setState(() => _silmeModuAktif[index] = false),
                                child: AnimatedOpacity(
                                  opacity: _silmeModuAktif[index] == true ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 200),
                                  child: GestureDetector(
                                    onTap: () async{
                                      bool res = await deleteMovie(film.movieID);
                                      if(res){
                                        _getMovies();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Film kaldırıldı',
                                            ),
                                          ),
                                        );
                                      }
                                      else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Film Silinemedi',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text("Filmi Envanterden Kaldır", style: TextStyle(color: Colors.white),),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}