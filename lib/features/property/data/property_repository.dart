import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class PropertyRepository {
  final pb = authRepo.pbInstance;

  Future<void> addProperty({
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required double pricePerNight,
    required String ownerId,
    required List<File> images,
  }) async {
    try {
      // تجهيز ملفات الصور
      final List<http.MultipartFile> files = [];

      for (var image in images) {
        final fileBytes = await image.readAsBytes();
        final fileName = image.path.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();
        final contentType = (ext == 'png')
            ? MediaType('image', 'png')
            : MediaType('image', 'jpeg');

        final multipartFile = http.MultipartFile.fromBytes(
          'images', // يجب تكرار نفس الاسم
          fileBytes,
          filename: fileName,
          contentType: contentType,
        );

        files.add(multipartFile);
      }

      // البيانات النصية
      final body = {
        'title': title,
        'description': description,
        'address': address,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'pricePerNight': pricePerNight,
        'ownerId': ownerId,
        'isAvailable': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 🚩 الخطوة الأهم: الرفع على خطوتين لضمان رفع الصور جميعها
      // 1️⃣ إنشاء العقار بدون صور أولًا
      final record = await pb.collection('properties').create(body: body);

      // 2️⃣ رفع الصور باستخدام update لضمان رفع جميع الصور
      await pb.collection('properties').update(
        record.id,
        files: files, // رفع جميع الصور
      );

      print('✅ تم رفع العقار مع الصور بنجاح.');
    } catch (e) {
      print('❌ خطأ أثناء رفع العقار: $e');
      if (e is ClientException) {
        print('📌 تفاصيل الخطأ: ${e.response}');
      }
      rethrow;
    }
  }
}
