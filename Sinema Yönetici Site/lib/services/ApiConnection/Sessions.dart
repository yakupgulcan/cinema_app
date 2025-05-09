import 'dart:convert';

import '../../models/Session.dart';
import 'package:http/http.dart' as http;

String serverAddress = "http://127.0.0.1:5000";

Future<List<Session>?> getSessionsByDate(String date) async {
  http.Response _response = await http.get(
    Uri.parse('$serverAddress/sessions/$date'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<Session> sessions = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    sessions.add(Session.fromJson(data));
  }
  return sessions;
}

Future<bool> deleteSession(int id) async {
  http.Response _response = await http.delete(
    Uri.parse('$serverAddress/session/$id'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return false;
  }
  return true;
}

Future<int?> createSession({
  required int movieID,
  required int hallId,
  required String date,
  required String sessionNo,
}) async {
  String apiUrl = '$serverAddress/AddSession'; // Sunucu adresini buraya girin

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'movieID': movieID,
      'hallID': hallId,
      'date': date,
      'sessionNo': sessionNo,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)['sessionID'];
  } else {
    print(response.statusCode);
    print(jsonDecode(response.body));
    return null;
  }
}