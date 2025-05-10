import 'dart:convert';

import '../../models/Movie.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_yonetim_sistemi/constants/globals.dart';

Future<List<Movie>?> getMovies(String? genre) async {
  http.Response _response = await http.get(
    Uri.parse(genre != null ? '$serverAddress/movies?genre=$genre': '$serverAddress/movies'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<Movie> movies = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    movies.add(Movie.fromJson(data));
  }
  return movies;
}

Future<List<Movie>?> getRecommendedMovies() async {
  http.Response _response = await http.get(
      Uri.parse('$serverAddress/movies/popular'),
      );
      if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<Movie> movies = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    movies.add(Movie.fromJson(data));
  }
  return movies;
}

Future<List<Movie>?> getBestRatedMovies(bool weekly) async {
  http.Response _response = await http.get(
    Uri.parse(weekly ? '$serverAddress/movies/weekly-best-rated': '$serverAddress/movies/best-rated'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<Movie> movies = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    movies.add(Movie.fromJson(data));
  }
  return movies;
}

Future<List<Movie>?> getmostRatedMovies(bool weekly) async {
  http.Response _response = await http.get(
    Uri.parse(weekly ? '$serverAddress/movies/weekly-most-rated': '$serverAddress/movies/most-rated'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<Movie> movies = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    movies.add(Movie.fromJson(data));
  }
  return movies;
}

Future<bool> deleteMovie(int id) async {
  http.Response _response = await http.delete(
    Uri.parse('$serverAddress/movies/$id'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return false;
  }
  return true;
}