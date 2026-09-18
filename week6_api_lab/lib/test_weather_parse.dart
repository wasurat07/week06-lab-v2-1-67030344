import 'dart:convert';
import 'models/weather.dart'; // ปรับ path ให้ตรงกับตำแหน่งไฟล์จริงในโปรเจกต์

void main() {
  // TODO: แทนที่ข้อความด้านล่างด้วย Response Body จริงที่คัดลอกมาจาก Postman ในขั้นตอนที่ 1.1
  const rawJson = '''
  {
    "coord": {
        "lon": 100.5167,
        "lat": 13.75
    },
    "weather": [
        {
            "id": 500,
            "main": "Rain",
            "description": "ฝนเบา ๆ",
            "icon": "10d"
        }
    ],
    "base": "stations",
    "main": {
        "temp": 30.64,
        "feels_like": 36.65,
        "temp_min": 28.84,
        "temp_max": 31.61,
        "pressure": 1008,
        "humidity": 70,
        "sea_level": 1008,
        "grnd_level": 1007
    },
    "visibility": 10000,
    "wind": {
        "speed": 1.67,
        "deg": 264,
        "gust": 2.08
    },
    "rain": {
        "1h": 1
    },
    "clouds": {
        "all": 92
    },
    "dt": 1789712774,
    "sys": {
        "type": 2,
        "id": 2112373,
        "country": "TH",
        "sunrise": 1789686417,
        "sunset": 1789730264
    },
    "timezone": 25200,
    "id": 1609350,
    "name": "กรุงเทพมหานคร",
    "cod": 200
  }
  ''';

  final json = jsonDecode(rawJson) as Map<String, dynamic>;
  final weather = Weather.fromJson(json);

  print('cityName: ${weather.cityName}');
  print('temperature: ${weather.temperature}');
  print('description: ${weather.description}');
  print('feelsLike: ${weather.feelsLike}');
}