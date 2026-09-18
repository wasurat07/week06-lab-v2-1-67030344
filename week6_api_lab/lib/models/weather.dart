class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final double feelsLike;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.feelsLike,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // 1. ดึง object ย่อย 'main' และ cast อุณหภูมิต่างๆ
    final main = json['main'] as Map<String, dynamic>;
    final temperature = (main['temp'] as num).toDouble();
    final feelsLike = (main['feels_like'] as num).toDouble();

    // 2. cast 'weather' เป็น List และดึงสมาชิกตัวแรกเพื่อเอา description
    final weatherList = json['weather'] as List<dynamic>;
    final weatherFirst = weatherList[0] as Map<String, dynamic>;
    final description = weatherFirst['description'] as String;

    // 3. ดึง cityName จาก key 'name' ที่ระดับบนสุด
    final cityName = json['name'] as String;

    return Weather(
      cityName: cityName,
      temperature: temperature,
      description: description,
      feelsLike: feelsLike,
    );
  }
}