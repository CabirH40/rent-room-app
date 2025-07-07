import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart'; // استورد الريبو المحدث مع PocketBase
import '../../auth/presentation/pages/auth_page.dart';

class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({super.key});

  Future<List<RecordModel>> _getBookings(String ownerId) async {
    final pb = authRepo.pbInstance;
    final result = await pb.collection('bookings').getFullList(
      filter: 'ownerId="$ownerId"',
      sort: '-created', // الأحدث أولاً
      expand: 'propertyId,userId', // جلب العقار والمستأجر معاً
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('يجب تسجيل الدخول كمؤجر لرؤية الحجوزات')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي (كمؤجر)')),
      body: FutureBuilder<List<RecordModel>>(
        future: _getBookings(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('لا يوجد حجوزات حتى الآن'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, idx) {
              final booking = bookings[idx];
              final property = booking.expand['propertyId'] as RecordModel?;
              final tenant = booking.expand['userId'] as RecordModel?;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: property != null && property.getListValue('images').isNotEmpty
                      ? Image.network(
                    property.getListValue('images')[0],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.home, size: 50, color: Colors.grey),
                  title: Text(property?.getStringValue('title') ?? 'عقار غير معروف'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'تاريخ الحجز: ${_formatDate(booking.getStringValue('startDate'))} - ${_formatDate(booking.getStringValue('endDate'))}'),
                      Text(
                        'الحالة: ${_getStatusLabel(booking.getStringValue('status'))}',
                        style: TextStyle(
                          color: _statusColor(booking.getStringValue('status')),
                        ),
                      ),
                    ],
                  ),
                  trailing: Text('المستأجر: ${tenant?.getStringValue('name') ?? 'مجهول'}'),
                  onTap: () {
                    // يمكنك هنا فتح صفحة تفاصيل الحجز أو اتخاذ إجراء
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(String? iso) {
    // توقع أن التاريخ محفوظ كـ ISO8601 string
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}/${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }

  static String _getStatusLabel(String? status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'pending':
        return 'معلق';
      case 'cancelled':
        return 'ملغى';
      case 'completed':
        return 'مكتمل';
      default:
        return status ?? '';
    }
  }

  static Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.black54;
    }
  }
}
