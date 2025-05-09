import 'dart:convert';

import '../../models/Movie.dart';
import 'package:http/http.dart' as http;
import 'package:cinema_app/globals/globals.dart';

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