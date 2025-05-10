import 'package:cinema_app/screens/Bilet/ticket_booking.dart';
import 'package:cinema_app/services/Auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cinema_app/models/Movie.dart';
import 'package:cinema_app/globals/globals.dart';
import 'package:provider/provider.dart';

import '../../providers/userProvider.dart';
import '../Giris_Kayit/auth_screen.dart';

// Eğer bu dosyada carousel_slider kullanılacaksa, aşağıdaki import ifadesini ekleyin
// import 'package:carousel_slider/carousel_slider.dart' hide CarouselController;

class MovieDetailPage extends StatelessWidget {
  final Movie movie;
  
  const MovieDetailPage({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Film posteri ve bilgileri
            Stack(
              children: [
                // Arkaplan posteri
                Container(
                  height: 500,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('$serverAddress/images/${movie.movieID}'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Film bilgileri
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.movieName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              movie.movieGenre ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          RatingBar.builder(
                            initialRating: movie.averagePoint ?? 5.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${movie.averagePoint}/10',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${movie.duration! ~/ 60} saat, ${movie.duration! % 60} dakika',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Film açıklaması
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Özet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.description??"",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  // Yönetmen
                  const Text(
                    'Yönetmen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.director??"",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  // Bilet al butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async{
                        var customerProvider =
                        Provider.of<CustomerProvider>(context, listen: false);
                        if(customerProvider.customerID != null){
                          Navigator.push(context, MaterialPageRoute(builder: (ctx) => TicketBookingPage(movie: movie,)));                        }
                        else{
                          Navigator.push(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Bilet Al',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Fragman butonu
                  /*SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Fragmanı İzle',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}