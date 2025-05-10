import 'package:flutter/material.dart';
import 'package:cinema_app/models/Movie.dart';
import 'package:cinema_app/screens/AnaSayfa/AnaSayfa.dart';


class MovieListPage extends StatefulWidget {
  final List<Movie> movies;

  const MovieListPage({Key? key, required this.movies}) : super(key: key);

  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<Movie> filteredMovies = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController nameFilterController = TextEditingController();
  double minRating = 0.0;
  int minDuration = 0;
  int maxDuration = 400;

  @override
  void initState() {
    super.initState();
    filteredMovies = widget.movies;
    searchController.addListener(_filterMovies);
    nameFilterController.addListener(_filterMovies);
  }

  void _filterMovies() {
    setState(() {
      filteredMovies = widget.movies.where((movie) {
        final searchText = searchController.text.toLowerCase();
        final nameFilterText = nameFilterController.text.toLowerCase();
        final matchesSearch = movie.movieName.toLowerCase().contains(searchText) ||
            (movie.movieGenre?.toLowerCase().contains(searchText) ?? false) ||
            (movie.description?.toLowerCase().contains(searchText) ?? false);
        final matchesName = movie.movieName.toLowerCase().contains(nameFilterText);
        final matchesRating = minRating == 0  || movie.averagePoint != null && movie.averagePoint! >= minRating;
        final matchesDuration = minDuration==0 && maxDuration == 400 || movie.duration != null &&
            movie.duration! >= minDuration &&
            movie.duration! <= maxDuration;
        return matchesSearch && matchesName && matchesRating && matchesDuration;
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    nameFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Movies', style: TextStyle(color: Colors.white),),
        elevation: 4,
        backgroundColor: Colors.grey[850], // Darker app bar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[850], // Dark filter container
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameFilterController,
                    decoration: InputDecoration(
                      labelText: 'Filter by Movie Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800], // Dark input field
                      prefixIcon: const Icon(Icons.movie, color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: TextStyle(color: Colors.grey[300]),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Genre or Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800], // Dark input field
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: TextStyle(color: Colors.grey[300]),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minimum Rating: ${minRating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[300],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0.0', style: TextStyle(color: Colors.grey)),
                          Text('5.0', style: TextStyle(color: Colors.grey)),
                          Text('10.0', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Slider(
                        value: minRating,
                        min: 0.0,
                        max: 10.0,
                        divisions: 20,
                        label: minRating.toStringAsFixed(1),
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey[700],
                        onChanged: (value) {
                          setState(() {
                            minRating = value;
                            _filterMovies();
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration Range: $minDuration - $maxDuration min',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[300],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0 min', style: TextStyle(color: Colors.grey)),
                          Text('200 min', style: TextStyle(color: Colors.grey)),
                          Text('400 min', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      RangeSlider(
                        values: RangeValues(minDuration.toDouble(), maxDuration.toDouble()),
                        min: 0,
                        max: 400,
                        divisions: 30,
                        labels: RangeLabels(
                          minDuration.toString(),
                          maxDuration.toString(),
                        ),
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey[700],
                        onChanged: (RangeValues values) {
                          setState(() {
                            minDuration = values.start.toInt();
                            maxDuration = values.end.toInt();
                            _filterMovies();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Movie Grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: filteredMovies[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}