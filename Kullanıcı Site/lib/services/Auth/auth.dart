import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinema_app/globals/globals.dart';
Future<int?> signUp({
  required String name,
  required String password,
}) async {
  String apiUrl = '$serverAddress/signUp'; // Sunucu adresini buraya girin

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)['customerID'];
  } else {
    print(response.statusCode);
    print(jsonDecode(response.body));
    return null;
  }
}

Future<List<int>?> signIn({
  required String name,
  required String password,
}) async {
  String apiUrl = '$serverAddress/signIn'; // Sunucu adresini buraya girin

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    List<int> sonuclar = [];
    final res = jsonDecode(response.body);
    sonuclar.add(res['status']);
    if(res['status'] != 0)
      sonuclar.add(res['customerID']);
    return sonuclar;
  } else {
    print(response.statusCode);
    print(jsonDecode(response.body));
    return null;
  }
}

Future<bool> deleteUser(int id) async {
  http.Response _response = await http.delete(
    Uri.parse('$serverAddress/users/$id'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return false;
  }
  return true;
}