import 'services/weather_dio_service.dart';

void main() async {
  print('กำลังดึงข้อมูลสภาพอากาศด้วย Dio...');
  try {
    final weather = await fetchWeatherWithDio('Bangkok');
    print('--- ดึงข้อมูลสำเร็จด้วย Dio ---');
    print('cityName: ${weather.cityName}');
    print('temperature: ${weather.temperature}');
    print('description: ${weather.description}');
    print('feelsLike: ${weather.feelsLike}');
  } catch (e) {
    print('เกิดข้อผิดพลาด: $e');
  }
}