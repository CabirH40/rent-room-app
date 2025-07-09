import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class BookingPage extends StatefulWidget {
  final String propertyId;
  const BookingPage({super.key, required this.propertyId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  File? proofFile;
  bool isLoading = false;

  Future<void> pickProofFile() async {
    if (Platform.isAndroid) {
      // طلب الصلاحيات الحديثة
      final imageStatus = await Permission.photos.request();
      final videoStatus = await Permission.videos.request();
      final audioStatus = await Permission.audio.request();

      if (!imageStatus.isGranted && !videoStatus.isGranted && !audioStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى منح صلاحية الوصول للملفات')),
        );
        return;
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        proofFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitBooking() async {
    if (proofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى رفع إيصال التحويل أولاً')),
      );
      return;
    }
    setState(() => isLoading = true);

    try {
      final bookingData = {
        'tenantId': authRepo.currentUser!.id,
        'propertyId': widget.propertyId,
        'status': 'pending',
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      };

      final fileName = proofFile!.path.split('/').last;
      final fileBytes = await proofFile!.readAsBytes();

      final multipartFile = MultipartFile.fromBytes(
        'proof',
        fileBytes,
        filename: fileName,
      );

      await authRepo.pbInstance.collection('bookings').create(
        body: bookingData,
        files: [multipartFile],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الحجز بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authRepo.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الحجز')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اسم المستأجر: ${user?.data['name'] ?? ''}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text('يرجى تحويل الأجرة إلى الحساب التالي:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            const SelectableText(
              'TR00 0000 0000 0000 0000 0000 00',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickProofFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('رفع صورة أو PDF الإيصال'),
            ),
            if (proofFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('تم اختيار: ${proofFile!.path.split('/').last}'),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : submitBooking,
                icon: const Icon(Icons.send),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال طلب الحجز'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
