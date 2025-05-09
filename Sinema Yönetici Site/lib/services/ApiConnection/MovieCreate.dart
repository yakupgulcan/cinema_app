import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverAddress = "http://127.0.0.1:5000";

Future<int?> uploadMovie({
  required String movieName,
  required int duration,
  required String movieGenre,
  required String movieType,
  required String description,
  required String director,
  String? trailerUrl,
  double? popularityPoint,
  double? averagePoint,
}) async {
  String apiUrl = '$serverAddress/upload_movie'; // Sunucu adresini buraya girin

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'movieName': movieName,
      'duration': duration,
      'movieGenre': movieGenre,
      'movieType': movieType,
      'description': description,
      'director': director,
      if (trailerUrl != null) 'trailerUrl': trailerUrl,
      if (popularityPoint != null) 'popularity_point': popularityPoint,
      if (averagePoint != null) 'average_point': averagePoint,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)['movie_id'];
  } else {
    print(response.statusCode);
    print(jsonDecode(response.body));
    return null;
  }
}