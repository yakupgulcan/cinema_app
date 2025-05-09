import 'package:cinema_app/globals/globals.dart';
import 'package:cinema_app/models/Movie.dart';
import 'package:cinema_app/services/ApiConnection/MovieRating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../providers/userProvider.dart';


class MovieRatingPage extends StatefulWidget {
  List<Movie> movies;
  MovieRatingPage({super.key, required this.movies});

  @override
  State<MovieRatingPage> createState() => _MovieRatingPageState();
}

class _MovieRatingPageState extends State<MovieRatingPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<double> _movieRatings = [];
  List<bool> _isRatedList = [];
  // Film listesi
  void _searchMovie(String query) {
    if (query.isEmpty) return;
    
    // Arama sorgusuna göre film bulma
    final lowerCaseQuery = query.toLowerCase();
    for (int i = 0; i < widget.movies.length; i++) {
      if (widget.movies[i].movieName.toString().toLowerCase().contains(lowerCaseQuery)) {
        // Bulunan filme kaydır
        // _carouselController.animateToPage(i); // ListView.builder'da bu gerekli değil
        // ListView.builder'da belirli bir öğeye kaydırmak için ScrollController kullanılabilir.
        // Şimdilik bu özelliği devre dışı bırakıyorum, gerekirse daha sonra eklenebilir.
        _scrollController.animateTo(
          i * 250.0, // Her bir öğenin yaklaşık yüksekliği (ayarlamanız gerekebilir)
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }
  
  @override
  void initState() {
    super.initState();
    // Her film için başlangıç değerlerini ayarla
    _movieRatings = List.generate(widget.movies.length, (index) => widget.movies[index].averagePoint?.toDouble() ?? 0.0);
    _isRatedList = List.generate(widget.movies.length, (index) => _movieRatings[index] > 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Film Puanlama', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              'Film Puanlama',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Arama alanı - daha kompakt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Film Arayın',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: _searchMovie,
            ),
          ),
          
          // Film Listesi - Dikey kaydırma
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Dikey kaydırma için ScrollController
              itemCount: widget.movies.length,
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                // isActive durumunu ListView.builder için uyarlamaya gerek yok,
                // çünkü tüm öğeler benzer şekilde görünecek.
                // _currentIndex değişkeni artık kullanılmıyor, kaldırılabilir veya farklı bir amaç için tutulabilir.

                return Container(
                  // Her bir film kartının görünümü
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Film posteri ve başlık yan yana
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              "$serverAddress/images/${movie.movieID}",
                              height: 150, // Poster yüksekliği
                              width: 100,  // Poster genişliği
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.movieName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20, // Başlık font boyutu
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tür: ${movie.movieGenre}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Yönetmen: ${movie.director}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // Puanlama yıldızları
                      Center(
                        child: RatingBar.builder(
                          initialRating: movie.userRating ?? 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                          unratedColor: Colors.white, // Ensure unrated stars are white
                          itemBuilder: (context, _) => Icon(
                            Icons.star, // The widget will handle if it's full, half or empty based on rating
                            color: Colors.amber, // Color for rated stars
                            size: 30,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              movie.userRating = rating;
                              _isRatedList[index] = rating > 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Puanlama butonu
                      Center(
                        child: ElevatedButton(
                          onPressed: _isRatedList[index] ? () async{
                            var customerProvider =
                            Provider.of<CustomerProvider>(context, listen: false);
                            int? id = await addMovieRating(customerId: customerProvider.customerID!, movieId: movie.movieID, rating: movie.userRating!);
                            if(id != null){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${movie.movieName} filmine ${movie.userRating} puan verdiniz!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRatedList[index] ? Colors.red : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'PUANLA!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}