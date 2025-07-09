import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../auth/data/auth_repository.dart';
import 'package:pocketbase/pocketbase.dart';

final authRepo = AuthRepository();

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();

  final List<XFile> _images = [];
  bool _loading = false;
  String message = '';

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images.clear();
        _images.addAll(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _images.isEmpty) {
      setState(() => message = 'يرجى تعبئة جميع الحقول وإضافة صور');
      return;
    }
    setState(() {
      _loading = true;
      message = '';
    });

    try {
      final user = authRepo.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول كمؤجر';
      final ownerId = user.id;

      // تجهيز الملفات للرفع عبر MultipartFile
      final List<http.MultipartFile> filesToUpload = [];
      for (final imgXFile in _images) {
        final fileBytes = await File(imgXFile.path).readAsBytes();
        final ext = imgXFile.name.split('.').last.toLowerCase();
        final contentType = (ext == 'png')
            ? MediaType('image', 'png')
            : MediaType('image', 'jpeg');

        final multipartFile = http.MultipartFile.fromBytes(
          'images', // يجب تكرار نفس الاسم لجميع الصور
          fileBytes,
          filename: imgXFile.name,
          contentType: contentType,
        );
        filesToUpload.add(multipartFile);
      }

      final body = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'pricePerNight': double.parse(_priceController.text.trim()),
        'ownerId': ownerId,
        'isAvailable': true,
      };

      // 🚩 رفع العقار بدون الصور أولاً
      final record = await authRepo.pbInstance.collection('properties').create(body: body);

      // 🚩 بعدها رفع الصور باستخدام update لضمان رفع جميع الصور
      await authRepo.pbInstance.collection('properties').update(
        record.id,
        files: filesToUpload,
      );

      setState(() {
        message = 'تم إضافة العقار مع الصور بنجاح!';
        _loading = false;
        _titleController.clear();
        _descriptionController.clear();
        _addressController.clear();
        _priceController.clear();
        _images.clear();
      });
    } catch (e) {
      setState(() {
        message = 'حدث خطأ أثناء الإضافة: $e';
        _loading = false;
      });
      print('❌ Error submitting property: $e');
      if (e is ClientException) {
        print('📌 PocketBase Error: ${e.response}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عقار جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان العقار'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'وصف العقار'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان أو المدينة'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'السعر لليلة'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('إضافة صور للعقار'),
              onPressed: _pickImages,
            ),
            const SizedBox(height: 10),
            _images.isNotEmpty
                ? SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _images
                    .map((img) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image.file(
                    File(img.path),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ))
                    .toList(),
              ),
            )
                : const Text('لم يتم اختيار صور بعد', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submit,
                child: const Text('إضافة العقار'),
              ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: message.contains('نجاح') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
