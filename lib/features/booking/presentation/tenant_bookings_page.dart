import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class TenantBookingsPage extends StatefulWidget {
  const TenantBookingsPage({super.key});

  @override
  State<TenantBookingsPage> createState() => _TenantBookingsPageState();
}

class _TenantBookingsPageState extends State<TenantBookingsPage> {
  List<RecordModel> bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _setupRealtimeListener();
  }

  Future<void> _fetchBookings() async {
    final currentUser = authRepo.currentUser;
    if (currentUser == null) return;

    final result = await authRepo.pbInstance.collection('bookings').getFullList(
      filter: 'tenantId="${currentUser.id}"',
      expand: 'propertyId',
      sort: '-created',
    );

    setState(() {
      bookings = result;
    });
  }

  void _setupRealtimeListener() {
    final currentUser = authRepo.currentUser;
    if (currentUser == null) return;

    authRepo.pbInstance.collection('bookings').subscribe('*', (e) async {
      // إذا كان التحديث يخص المستأجر الحالي، حدّث القائمة
      final record = e.record;
      if (record != null && record.getStringValue('tenantId') == currentUser.id) {
        _fetchBookings();
      }
    });
  }

  @override
  void dispose() {
    authRepo.pbInstance.collection('bookings').unsubscribe('*');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: bookings.isEmpty
          ? const Center(child: Text('لا يوجد حجوزات حالياً'))
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final property = booking.expand['propertyId'] as RecordModel?;
          final propertyImage = property != null && property.getListValue('images').isNotEmpty
              ? '${authRepo.pbInstance.baseUrl}/api/files/${property.collectionId}/${property.id}/${property.getListValue('images')[0]}'
              : null;

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: propertyImage != null
                  ? Image.network(propertyImage, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.home, size: 40, color: Colors.grey),
              title: Text(property?.getStringValue('title') ?? 'عقار غير معروف'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('من: ${booking.getStringValue('startDate')?.substring(0, 10)}'),
                  Text('إلى: ${booking.getStringValue('endDate')?.substring(0, 10)}'),
                  Text('الحالة: ${_getStatusLabel(booking.getStringValue('status'))}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'pending':
        return 'قيد الانتظار';
      case 'rejected':
        return 'مرفوض';
      default:
        return status ?? '';
    }
  }
}
