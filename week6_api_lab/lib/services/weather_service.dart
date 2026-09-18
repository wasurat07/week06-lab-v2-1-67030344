import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const _apiKey = 'd0c798108d76df773dd7c11fd28d122b'; // เปลี่ยนเป็น API Key จริงของคุณเมื่อทดสอบ

  Future<Weather> fetchWeather(String city) async {
    final uri = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=th');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('ไม่พบข้อมูลเมืองที่ระบุ');
      } else if (response.statusCode == 401) {
        throw Exception('API Key ไม่ถูกต้องหรือยังไม่เปิดใช้งาน');
      } else {
        throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
    } on FormatException {
      throw Exception('รูปแบบข้อมูลที่ได้รับไม่ถูกต้อง');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}