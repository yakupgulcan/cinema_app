import 'dart:convert';

import 'package:http/http.dart' as http;

String serverAddress = "http://127.0.0.1:5000";

Future<int?> getConcessionsQuantity(String item_name) async {
  http.Response _response = await http.get(
    Uri.parse('$serverAddress/concession?item_name=$item_name'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return null;
  }
  int quantity = jsonDecode(_response.body)['stockQuantity'];
  return quantity;
}

Future<bool> updateConcessionsQuantity(String item_name, int item_count) async {
  http.Response _response = await http.put(
    Uri.parse('$serverAddress/concession?item_name=$item_name&item_count=$item_count'),
  );
  if(_response.statusCode != 200){
    print(_response.statusCode);
    print(json.decode(_response.body));
    return false;
  }
  return true;
}