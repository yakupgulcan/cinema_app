import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinema_app/globals/globals.dart';

Future<int?> addMovieRating({
  required int customerId,
  required int movieId,
  required double rating,
}) async {
  const String apiUrl = '$serverAddress/add_movie_rating'; // Flask endpoint adresi

  // Bugünün tarihini YYYY-MM-DD formatında al
  final String ratingDate = DateTime.now().toIso8601String().split('T')[0];

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'customer_id': customerId,
      'movie_id': movieId,
      'rating': rating,
      'rating_date': ratingDate,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)['result_id'];
  } else {
    print('Error: ${response.statusCode}');
    print('Response: ${jsonDecode(response.body)}');
    return null;
  }
}