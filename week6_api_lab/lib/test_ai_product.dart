import 'services/ai_product_service.dart';

void main() async {
  print('กำลังดึงข้อมูลสินค้าจาก API...');
  try {
    final products = await fetchAiProducts();
    print('--- ดึงข้อมูลสำเร็จ! ได้สินค้าทั้งหมด ${products.length} ชิ้น ---');
    
    // แสดงตัวอย่างสินค้า 3 ชิ้นแรก
    for (var i = 0; i < 3 && i < products.length; i++) {
      final p = products[i];
      print('ชิ้นที่ ${i + 1}: ${p.title} | ราคา: \$${p.price}');
    }
  } catch (e) {
    print('เกิดข้อผิดพลาด: $e');
  }
}