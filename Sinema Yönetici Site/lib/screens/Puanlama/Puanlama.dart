import 'package:flutter/material.dart';
import 'package:sinema_yonetim_sistemi/constants/globals.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/GetMovies.dart';
import 'package:sinema_yonetim_sistemi/widgets/Loading.dart';

import '../../models/Movie.dart';

// Renk Tanımlamaları (Stok Yönetimi Sayfasına Benzer)
const Color primaryColor = Color(0xFF607D8B); // Mavi Gri
const Color accentColor = Color(0xFF03A9F4); // Açık Mavi
const Color backgroundColor = Color(0xFFECEFF1); // Çok Açık Gri
const Color textColorPrimary = Colors.black87;
const Color textColorSecondary = Colors.black54;

class FilmPuanlariPage extends StatefulWidget {
  @override
  State<FilmPuanlariPage> createState() => _FilmPuanlariPageState();
}

class _FilmPuanlariPageState extends State<FilmPuanlariPage> {
  // Örnek film verileri (afiş URL'leri veya yerel asset yolları ile güncellenmeli)
  List<Movie> recommendedFilms = [];

  List<Movie> mostRatedFilms = [];

  List<Movie> bestRatedFilms = [];

  List<Movie> mostRatedAllTimesFilms = [];

  List<Movie> bestRatedAllTimesFilms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Loadingscreen(
        task: () async{
          recommendedFilms = await getRecommendedMovies() ?? [];
          mostRatedFilms = await getmostRatedMovies(true) ?? [];
          mostRatedAllTimesFilms = await getmostRatedMovies(false) ?? [];
          bestRatedFilms = await getBestRatedMovies(true) ?? [];
          bestRatedAllTimesFilms = await getBestRatedMovies(false) ?? [];
          setState(() {

          });
        },
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            _buildSectionTitle(context, 'Ek Seans Eklenmesi Önerilen Filmler'),
            _buildRecommendedFilmList(context, recommendedFilms),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Bu Hafta En Çok Puanlananlar'),
            _buildFilmListWithCount(context, mostRatedFilms),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Bu Hafta En Yüksek Puan Ortalaması Alanlar'),
            _buildFilmListWithRating(context, bestRatedFilms),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Tüm Zamanlar En Çok Puanlananlar'),
            _buildFilmListWithCount(context, mostRatedAllTimesFilms),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Tüm Zamanlar En Yüksek Puan Ortalaması'),
            _buildFilmListWithRating(context, bestRatedAllTimesFilms),
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

  Widget _buildFilmListWithCount(BuildContext context, List<Movie> films) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: films.isNotEmpty ? films.map((film) {
            return ListTile(
              title: Text(film.movieName, style: TextStyle(fontSize: 16, color: textColorPrimary, fontWeight: FontWeight.w500)),
              trailing: Text('${film.ratingCount} puanlama', style: TextStyle(fontSize: 14, color: textColorSecondary)),
            );
          }).toList():[],
        ),
      ),
    );
  }

  Widget _buildFilmListWithRating(BuildContext context, List<Movie> films) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: films.map((film) {
            return ListTile(
              title: Text(film.movieName, style: TextStyle(fontSize: 16, color: textColorPrimary, fontWeight: FontWeight.w500)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('${film.averagePoint}', style: TextStyle(fontSize: 14, color: textColorSecondary, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 20),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecommendedFilmList(BuildContext context, List<Movie> films) {
    return Container(
      height: 280, // Afiş ve metin için yeterli yükseklik
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films[index];
          return Container(
            width: 180, // Kart genişliği
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              clipBehavior: Clip.antiAlias, // Köşeleri yuvarlatılmış resim için
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      "$serverAddress/images/${film.movieID}",
                      fit: BoxFit.cover,
                      // Hata durumunda gösterilecek widget
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.movie_creation_outlined, size: 50, color: Colors.grey[400]),
                        );
                      },
                      // Yüklenirken gösterilecek widget
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: accentColor,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      film.movieName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColorPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}