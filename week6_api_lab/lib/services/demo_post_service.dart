import 'dart:convert';
import 'package:http/http.dart' as http;

// ฟังก์ชันเดิมจาก 3.1 ...

Future<void> updateDemoPost() async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'id': 1,
      'studentid': 67030344,
      'name': 'วสุรัตน์ มณีรัตนะพร',
      'faculty': 'ครุศาสตร์อุตสาหกรรมและเทคโนโลยี',
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');
}