import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

String serverAddres = "http://127.0.0.1:5000";

Future<String?> uploadFile(BuildContext context, Uint8List? selectedFile, int movieId) async{
  if(selectedFile == null){
    print("Dosya Seçilmedi");
    return null;
  }

  var uri = Uri.parse('$serverAddres/upload_media');

  final multipartFile = http.MultipartFile.fromBytes(
    'file',
    selectedFile,
    filename: 'movie:$movieId.jpg', // rastgele bir isim ver, önemli
  );

  final request = http.MultipartRequest('POST', uri)
    ..fields['movieID'] = '1'
    ..files.add(multipartFile);
  var streamedResponse = await request.send();

  final responseBody = await streamedResponse.stream.bytesToString();
  if(streamedResponse.statusCode != 200){
    print(streamedResponse.statusCode);
    return null;
  }

  return responseBody;
}
