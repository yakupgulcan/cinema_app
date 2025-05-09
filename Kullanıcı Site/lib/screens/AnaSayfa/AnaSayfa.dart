import 'dart:async';

import 'package:cinema_app/screens/Puanlama/movie_rating.dart';
import 'package:cinema_app/screens/TumFilmler/Tum_Filmler.dart';
import 'package:cinema_app/screens/Ulasim/ulasim.dart';
import 'package:cinema_app/services/Auth/auth.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter_rating_bar/flutter_rating_bar.dart' show RatingBar;
import 'package:cinema_app/screens/FilmDetay/movie_detail.dart';
import 'package:cinema_app/screens/Giris_Kayit/auth_screen.dart';
import 'package:cinema_app/widgets/Loading.dart';
import 'package:cinema_app/models/Movie.dart';
import 'package:cinema_app/services/ApiConnection/ApiConnection.dart';
import 'package:provider/provider.dart';

import '../../providers/userProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Movie> BuHaftaFimler = [];
  List<Movie> EnSevilenFilmler = [];
  List<Movie> YeniCikanFilmler = [];
  List<Movie> KlasikFilmler = [];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;

  late CustomerProvider customerProvider;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutSectionKey = GlobalKey();

  void _scrollToAboutSection() {
    final RenderObject? renderObject = _aboutSectionKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      _scrollController.animateTo(
        position.dy,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 150,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(-100, 40), // butonun hemen altı
          showWhenUnlinked: false,
          child: MouseRegion(
            onExit: (_) {
              _hideTimer = Timer(Duration(seconds: 2), _removeOverlay);
            },
            onEnter: (_) {
              _hideTimer?.cancel();
            },
            child: Material(
              elevation: 4,
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async{
                        await deleteUser(customerProvider.customerID!);
                        customerProvider.setCustomerID(null);
                        setState(() {
                        });
                        _removeOverlay();
                      },
                      child: Text("Hesabı Sil", style: TextStyle(color: Colors.red),),
                    ),
                    TextButton(
                      onPressed: () {
                        customerProvider.setCustomerID(null);
                        setState(() {
                        });
                        _removeOverlay();
                      },
                      child: Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontSize: 20),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    customerProvider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      body: Loadingscreen(
        task: ()async{
          BuHaftaFimler = await getMovies(null) ?? [];
          EnSevilenFilmler = await getMovies(null) ?? [];
          YeniCikanFilmler = await getMovies('Yeni') ?? [];
          KlasikFilmler = await getMovies('Klasik') ?? [];
          setState(() {

          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Row(
                  children: [
                    const Text(
                      'YILDIZ SİNEMALARI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 30),
                    NavItem(title: 'Tüm Filmler', fontSize: 18, onTap: ()async{
                      List<Movie> allMovies = await getMovies(null) ?? [];
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => MovieListPage(movies: allMovies)));
                    },),
                    const SizedBox(width: 25),
                    NavItem(title: 'Film Puanlama', fontSize: 18, onTap: () async{
                      var customerProvider =
                      Provider.of<CustomerProvider>(context, listen: false);
                      if(customerProvider.customerID != null){
                        List<Movie> allMovies = await getMovies(null) ?? [];
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => MovieRatingPage(movies: allMovies,)));
                      }
                      else{
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
                      }
                    },),
                    const SizedBox(width: 25),
                    NavItem(title: 'Ulaşım', fontSize: 18, onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => UlasimPage()));
                    },),
                    const SizedBox(width: 25),
                    NavItem(title: 'Hakkımızda', fontSize: 18, onTap: _scrollToAboutSection,),
                    const Spacer(),
                    customerProvider.customerID == null?
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(color: Colors.white),
                      ),
                    ):
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: OutlinedButton(
                        onPressed: _toggleOverlay,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Profil',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),

              // Bu Hafta Sinemalarda Section
              const SectionTitle(title: 'Bu Hafta Sinemalarda!'),
              carousel_slider.CarouselSlider(
                options: carousel_slider.CarouselOptions(
                  height: 400,
                  viewportFraction: 0.25, // Tam 4 öğe sığması için 1/4
                  padEnds: false, // Kenarlardaki varsayılan boşluğu kaldır
                  enlargeCenterPage: false,
                  autoPlay: true,
                  aspectRatio: 16/9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                ),
                items: List.generate(BuHaftaFimler.length, (itm){
                  return MovieCard(movie: BuHaftaFimler[itm]);
                }),
              ),

              // En Beğenilenler Section
              const SectionTitle(title: 'En Beğenilenler'),
              carousel_slider.CarouselSlider(
                options: carousel_slider.CarouselOptions(
                  height: 400,
                  viewportFraction: 0.25, // Tam 4 öğe sığması için 1/4
                  padEnds: false, // Kenarlardaki varsayılan boşluğu kaldır
                  enlargeCenterPage: false,
                ),
                items: List.generate(EnSevilenFilmler.length, (itm){
                  return MovieCard(movie: EnSevilenFilmler[itm]);
                }),
              ),

              // Yeni Çıkanlar Section
              const SectionTitle(title: 'Yeni Çıkanlar'),
              carousel_slider.CarouselSlider(
                options: carousel_slider.CarouselOptions(
                  height: 400,
                  viewportFraction: 0.25, // Tam 4 öğe sığması için 1/4
                  padEnds: false, // Kenarlardaki varsayılan boşluğu kaldır
                  enlargeCenterPage: false,
                ),
                items: List.generate(YeniCikanFilmler.length, (itm){
                  return MovieCard(movie: YeniCikanFilmler[itm]);
                }),
              ),

              // Klasik Filmler Section
              const SectionTitle(title: 'Klasik Filmler'),
              carousel_slider.CarouselSlider(
                options: carousel_slider.CarouselOptions(
                  height: 400,
                  viewportFraction: 0.25, // Tam 4 öğe sığması için 1/4
                  padEnds: false, // Kenarlardaki varsayılan boşluğu kaldır
                  enlargeCenterPage: false,
                ),
                items: List.generate(KlasikFilmler.length, (itm){
                  return MovieCard(movie: KlasikFilmler[itm]);
                }),
              ),

              const SizedBox(height: 50),

              // Hakkımızda Bölümü
              Container(
                key: _aboutSectionKey,
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HAKKIMIZDA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '- Yıldız Sinemaları, 2005 yılında kurulmuş olup bunca süredir kalifiye kadrosu ve yetenekli ekibiyle sizlere hizmet vermektedir.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '- Yıldız Alışveriş Merkezinin en üst katında son teknoloji ile donatılmış salonlarımızda, en yeni filmler, en iyi görüntü ve ses kalitesiyle sizleri beklemekteyiz.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "- Misyonumuz, sinema severlere unutulmaz bir deneyim yaşatmak ve film kültürünü yaygınlaştırmaktır. Vizyonumuz ise Türkiye'nin en kaliteli ve en çok ziyaret edilen şubesi olmaktır",
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '- Hızlı kayıt ve üyelik sistemimiz ile müşterilerimiz için en kolay yoldan bilet alma imkanı tanınmaktadır.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İLETİŞİM',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text('E-posta: info@yildizsinemalar.com', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 5),
                            const Text('Telefon: +90 212 123 45 67', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SOSYAL MEDYA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.facebook, color: Colors.white), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.video_library, color: Colors.white), onPressed: () {}),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Telif Hakkı Bilgisi
              Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  '© 2024 Yıldız Sinemaları. Tüm hakları saklıdır.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String title;
  final double fontSize;
  final Function()? onTap;

  const NavItem({Key? key, required this.title, this.fontSize = 16, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap ?? (){},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 40, bottom: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({
    Key? key, required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => MovieDetailPage(movie: movie)));
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'http://127.0.0.1:5000/images/${movie.movieID}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              movie.movieName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              movie.movieGenre??"",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            RatingBar.builder(
              initialRating: movie.averagePoint!,
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
          ], // children of Column closes
        ), // Column closes
      ), // Container closes
    ); // GestureDetector closes
  } // build method closes
} // MovieCard class closes