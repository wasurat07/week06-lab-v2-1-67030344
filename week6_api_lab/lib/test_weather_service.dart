import 'services/weather_service.dart';

void main() async {
  final service = WeatherService();

  // กรณีที่ 1: เรียกข้อมูลสำเร็จ (Bangkok)
  print('--- ทดสอบกรณีที่ 1: ดึงข้อมูลสำเร็จ ---');
  try {
    final weather = await service.fetchWeather('Bangkok');
    print('cityName: ${weather.cityName}');
    print('temperature: ${weather.temperature}');
    print('description: ${weather.description}');
    print('feelsLike: ${weather.feelsLike}');
  } catch (e) {
    print('เกิดข้อผิดพลาด: $e');
  }

  print('\n-----------------------------------\n');

  // กรณีที่ 2: เรียกเมืองที่ไม่พบ (404 Not Found)
  print('--- ทดสอบกรณีที่ 2: เมืองไม่มีอยู่จริง (404) ---');
  try {
    final weather = await service.fetchWeather('UnknownCity12345');
    print('cityName: ${weather.cityName}');
  } catch (e) {
    print('เกิดข้อผิดพลาด: $e');
  }
}