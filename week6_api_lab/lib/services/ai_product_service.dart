import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ============================================================================
// ส่วนที่ 1: Model Class ชื่อ AiProduct
// ============================================================================
class AiProduct {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  AiProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  /// factory fromJson ที่ cast ตัวเลขผ่าน num แล้วเรียก .toDouble() เสมอ
  /// ป้องกันปัญหาคลาสสิกของ Dart เมื่อ API คืนค่าเป็น int (เช่น 109) หรือ double (เช่น 109.95)
  factory AiProduct.fromJson(Map<String, dynamic> json) {
    return AiProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      // ⭐️ สำคัญ: cast ผ่าน num ก่อน แล้วค่อยเรียก .toDouble()
      // เนื่องจาก num เป็น supertype ของทั้ง int และ double ใน Dart
      // หากเขียน json['price'] as double จะแครชทันทีเมื่อ API คืนค่าเป็น int
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
    };
  }
}

// ============================================================================
// ส่วนที่ 2: ฟังก์ชัน fetchAiProducts() - ดึงรายการทั้งหมด (Future<List<AiProduct>>)
// ============================================================================
Future<List<AiProduct>> fetchAiProducts() async {
  final uri = Uri.parse('https://fakestoreapi.com/products');

  try {
    // -------------------------------------------------------------------------
    // [จุดที่ 1] ทำไมต้องตั้ง timeout ไม่เกิน 10 วินาที?
    // เหตุผล: ป้องกันกรณีเซิร์ฟเวอร์ FakeStoreAPI ช้า หรือเครือข่ายผู้ใช้ติดขัด (hanging state)
    // หากไม่กำหนด timeout ตัว Future จะค้างรอแบบไม่มีกำหนด ทำให้แอปดูเหมือนค้าง
    // -------------------------------------------------------------------------
    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
    );

    // -------------------------------------------------------------------------
    // [จุดที่ 2] ทำไมต้องเช็ค response.statusCode == 200?
    // เหตุผล: http.get() จะไม่มองว่า HTTP Status 404 หรือ 500 เป็น network failure
    // หากไม่เช็ค ระบบจะนำ body ที่เป็น HTML ข้อความ error ไป jsonDecode() จนแครช
    // -------------------------------------------------------------------------
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((item) => AiProduct.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw const FormatException('ข้อมูลที่ได้รับไม่ตรงกับรูปแบบรายการสินค้า');
      }
    } else {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ในขณะนี้ (รหัส: ${response.statusCode})');
    }
  } on TimeoutException {
    // -------------------------------------------------------------------------
    // [จุดที่ 3] ทำไมต้องดักจับ TimeoutException โดยเฉพาะ?
    // เหตุผล: เกิดขึ้นเมื่อ .timeout(10s) ครบกำหนดโดยที่เซิร์ฟเวอร์ยังตอบกลับไม่เสร็จ
    // แทนที่จะปล่อยให้แสดง "TimeoutException after 0:00:10.000000: Future not completed"
    // เราแปลงเป็นข้อความภาษาไทยแนะนำให้ผู้ใช้ตรวจสอบสัญญาณเน็ตและลองใหม่
    // -------------------------------------------------------------------------
    throw Exception('การเชื่อมต่อใช้เวลานานเกินไป กรุณาตรวจสอบอินเทอร์เน็ตและลองใหม่อีกครั้ง');
  } on http.ClientException {
    // -------------------------------------------------------------------------
    // [จุดที่ 4] ทำไมต้องดักจับ http.ClientException โดยเฉพาะ?
    // เหตุผล: เกิดขึ้นเมื่อระดับ HTTP Client ล้มเหลว เช่น ผู้ใช้ไม่ได้เชื่อมต่ออินเทอร์เน็ต
    // หรือ DNS lookup ล้มเหลวไม่พบโฮสต์ fakestoreapi.com
    // ข้อความเดิมคือ "ClientException: Failed host lookup..." ซึ่งผู้ใช้ไม่เข้าใจ
    // เราจึงแปลเป็นภาษาไทยตรงประเด็นว่าไม่สามารถเชื่อมต่อเครือข่ายได้
    // -------------------------------------------------------------------------
    throw Exception('ไม่สามารถเชื่อมต่อเครือข่ายได้ กรุณาตรวจสอบสัญญาณอินเทอร์เน็ตของคุณ');
  } on SocketException {
    // -------------------------------------------------------------------------
    // [จุดที่ 5] ทำไมต้องดักจับ SocketException โดยเฉพาะ?
    // เหตุผล: บนอุปกรณ์มือถือ (Android/iOS) เมื่อเน็ตหลุดหรือเปิดโหมดเครื่องบิน
    // ข้อผิดพลาดมักถูกโยนออกมาเป็น SocketException จากระดับ OS โดยตรง
    // -------------------------------------------------------------------------
    throw Exception('ไม่พบการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบ Wi-Fi หรือข้อมูลมือถือ');
  } on FormatException {
    // -------------------------------------------------------------------------
    // [จุดที่ 6] ทำไมต้องดักจับ FormatException โดยเฉพาะ?
    // เหตุผล: เกิดขึ้นเมื่อ jsonDecode() ล้มเหลว (เช่น ได้รับหน้า HTML error กลับมา)
    // หรือโครงสร้างที่ได้ไม่ใช่ List ของสินค้าตามที่คาดหวัง
    // -------------------------------------------------------------------------
    throw Exception('รูปแบบข้อมูลจากเซิร์ฟเวอร์ไม่ถูกต้อง ไม่สามารถแสดงผลได้');
  } catch (e) {
    // -------------------------------------------------------------------------
    // [จุดที่ 7] ทำไมต้อง catch ทั่วไป และเช็ค Exception ภาษาไทย?
    // เหตุผล: เพื่อรองรับข้อผิดพลาดที่ไม่คาดคิดอื่นๆ โดยหากเป็น Exception ที่เราแปลง
    // เป็นภาษาไทยไว้แล้วข้างต้น ให้ rethrow ส่งต่อไปแสดงบน UI ได้ทันที
    // -------------------------------------------------------------------------
    if (e is Exception && !e.toString().contains('Exception: [') && e.toString().startsWith('Exception: ')) {
      rethrow;
    }
    throw Exception('เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้งในภายหลัง');
  }
}

// ============================================================================
// ส่วนที่ 3: ฟังก์ชัน fetchAiProductById(int id) - ดึงรายการเดียว (Future<AiProduct>)
// ============================================================================
Future<AiProduct> fetchAiProductById(int id) async {
  // ตรวจสอบความถูกต้องของ id เบื้องต้น
  if (id <= 0) {
    throw Exception('รหัสสินค้าไม่ถูกต้อง กรุณาระบุรหัสที่เป็นจำนวนเต็มบวก');
  }

  final uri = Uri.parse('https://fakestoreapi.com/products/$id');

  try {
    // -------------------------------------------------------------------------
    // [จุดที่ 1] ตั้ง timeout 10 วินาที
    // เหตุผล: ป้องกันไม่ให้แอปค้างระหว่างดึงข้อมูลสินค้ารายชิ้น
    // -------------------------------------------------------------------------
    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
    );

    // -------------------------------------------------------------------------
    // [จุดที่ 2] ตรวจสอบ HTTP Status Code 200 และเนื้อหาว่างเปล่า
    // เหตุผล: FakeStoreAPI หากค้นหา ID ที่ไม่มีอยู่จริง บางครั้งคืน HTTP 200
    // แต่ body เป็นสตริงว่าง ("") หรือ "null" จึงต้องตรวจเช็คก่อน decode
    // -------------------------------------------------------------------------
    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body.trim() == 'null') {
        throw const FormatException('ไม่พบข้อมูลสินค้ารหัสนี้ในระบบ');
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return AiProduct.fromJson(decoded);
      } else {
        throw const FormatException('ข้อมูลสินค้าที่ได้รับไม่ตรงกับรูปแบบที่ถูกต้อง');
      }
    } else if (response.statusCode == 404) {
      throw Exception('ไม่พบรายการสินค้าที่ระบุ (รหัส: 404)');
    } else {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ในขณะนี้ (รหัส: ${response.statusCode})');
    }
  } on TimeoutException {
    // -------------------------------------------------------------------------
    // [จุดที่ 3] ทำไมต้องดักจับ TimeoutException โดยเฉพาะ?
    // เหตุผล: การเรียก GET /products/{id} ใช้เวลาเกิน 10 วินาที
    // แปลงเป็นข้อความไทยแจ้งผู้ใช้ให้ตรวจเน็ต แทนข้อความดิบสีแดงของ Future
    // -------------------------------------------------------------------------
    throw Exception('การเชื่อมต่อใช้เวลานานเกินไป กรุณาตรวจสอบอินเทอร์เน็ตและลองใหม่อีกครั้ง');
  } on http.ClientException {
    // -------------------------------------------------------------------------
    // [จุดที่ 4] ทำไมต้องดักจับ http.ClientException โดยเฉพาะ?
    // เหตุผล: อุปกรณ์ออฟไลน์, สัญญาณเน็ตหาย หรือ HTTP request ล้มเหลวระดับ Client
    // -------------------------------------------------------------------------
    throw Exception('ไม่สามารถเชื่อมต่อเครือข่ายได้ กรุณาตรวจสอบสัญญาณอินเทอร์เน็ตของคุณ');
  } on SocketException {
    // -------------------------------------------------------------------------
    // [จุดที่ 5] ทำไมต้องดักจับ SocketException โดยเฉพาะ?
    // เหตุผล: ข้อผิดพลาดระดับ OS Socket บนอุปกรณ์มือถือ (เน็ตหมด, โหมดเครื่องบิน)
    // -------------------------------------------------------------------------
    throw Exception('ไม่พบการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบ Wi-Fi หรือข้อมูลมือถือ');
  } on FormatException catch (e) {
    // -------------------------------------------------------------------------
    // [จุดที่ 6] ทำไมต้องดักจับ FormatException โดยเฉพาะ?
    // เหตุผล: JSON ผิดโครงสร้าง หรือกรณีคืนค่า null เมื่อหา ID ไม่เจอ
    // -------------------------------------------------------------------------
    if (e.message.isNotEmpty && !e.message.startsWith('Unexpected character')) {
      throw Exception(e.message);
    }
    throw Exception('รูปแบบข้อมูลสินค้าจากเซิร์ฟเวอร์ไม่ถูกต้อง ไม่สามารถแสดงผลได้');
  } catch (e) {
    // -------------------------------------------------------------------------
    // [จุดที่ 7] ส่งต่อ Exception ภาษาไทย หรือแปลง Error ที่คาดไม่ถึง
    // -------------------------------------------------------------------------
    if (e is Exception && !e.toString().contains('Exception: [') && e.toString().startsWith('Exception: ')) {
      rethrow;
    }
    throw Exception('เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้งในภายหลัง');
  }
}