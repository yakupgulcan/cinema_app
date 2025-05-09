import 'dart:convert';

import 'package:cinema_app/models/Session.dart';
import 'package:cinema_app/models/SessionSeat.dart';
import 'package:cinema_app/models/Ticket.dart';

import 'package:http/http.dart' as http;
import 'package:cinema_app/globals/globals.dart';

Future<List<Session>?> getSessions(int MovieId) async {
  http.Response _response = await http.get(
    Uri.parse('$serverAddress/sessions/$MovieId'),
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

Future<List<SessionSeat>?> getSessionSeats(int SessionId) async {
  http.Response _response = await http.get(
    Uri.parse('$serverAddress/seats/$SessionId'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }

  List<SessionSeat> seats = [];
  List<dynamic> _datas = jsonDecode(_response.body);
  for(Map<String, dynamic> data in _datas){
    seats.add(SessionSeat.fromJson(data));
  }
  return seats;
}

Future<int?> buyTicket({
  required Ticket ticket,
}) async {
  String apiUrl = '$serverAddress/buy_ticket'; // Sunucu adresini buraya girin

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(ticket.toJson()),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)['ticket_id'];
  } else {
    print(response.statusCode);
    print(jsonDecode(response.body));
    return null;
  }
}