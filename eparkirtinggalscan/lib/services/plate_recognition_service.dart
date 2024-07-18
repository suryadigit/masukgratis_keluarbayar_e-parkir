import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PlateRecognitionService {
  final String apiKey;

  PlateRecognitionService(this.apiKey);

  Future<String?> recognizePlate(String imagePath) async {
    final url = Uri.parse(
        'https://api.openalpr.com/v3/recognize_bytes?recognize_vehicle=1&country=us&secret_key=$apiKey');

    final bytes = File(imagePath).readAsBytesSync();
    final response = await http.post(url, body: bytes);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['plate'];
      }
    }
    return null;
  }
}
