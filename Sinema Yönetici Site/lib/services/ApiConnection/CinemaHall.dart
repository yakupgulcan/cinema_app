import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinema_yonetim_sistemi/constants/globals.dart';

import '../../models/CinemaHall.dart';

Future<List<Hall>?> getCinemaHalls() async {
  http.Response _response = await http.get(
    Uri.parse('$serverAddress/halls'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<Hall> halls = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    halls.add(Hall.fromJson(data));
  }
  return halls;
}