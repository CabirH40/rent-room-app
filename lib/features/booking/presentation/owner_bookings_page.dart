import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  Future<List<RecordModel>> fetchOwnerBookings() async {
    final pb = authRepo.pbInstance;
    final currentUser = authRepo.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final properties = await pb.collection('properties').getFullList(
      filter: 'ownerId = "${currentUser.id}"',
    );

    final propertyIds = properties.map((e) => e.id).toList();
    if (propertyIds.isEmpty) return [];

    final bookings = await pb.collection('bookings').getFullList(
      filter: propertyIds.map((id) => 'propertyId = "$id"').join(' || '),
      expand: 'propertyId,tenantId',
      sort: '-created',
    );

    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزات العقارات (كمؤجر)')),
      body: FutureBuilder<List<RecordModel>>(
        future: fetchOwnerBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات حالياً'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              // تعديل هنا
              final propertyList = booking.expand['propertyId'] as List<RecordModel>?;
              final property = propertyList != null && propertyList.isNotEmpty ? propertyList.first : null;

              final tenantList = booking.expand['tenantId'] as List<RecordModel>?;
              final tenant = tenantList != null && tenantList.isNotEmpty ? tenantList.first : null;

              final baseUrl = authRepo.pbInstance.baseUrl;
              final propertyImage = property != null && property.getListValue('images').isNotEmpty
                  ? '$baseUrl/api/files/${property.collectionId}/${property.id}/${property.getListValue('images')[0]}'
                  : null;

              final status = booking.getStringValue('status') ?? '';

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
                      Text('المستأجر: ${tenant?.getStringValue('name') ?? 'غير معروف'}'),
                      Text('من: ${booking.getStringValue('startDate')?.substring(0, 10) ?? ''}'),
                      Text('إلى: ${booking.getStringValue('endDate')?.substring(0, 10) ?? ''}'),
                      Text('الحالة: ${_statusLabel(status)}'),
                    ],
                  ),
                  trailing: (status == 'pending')
                      ? PopupMenuButton<String>(
                    onSelected: (value) async {
                      try {
                        await authRepo.pbInstance.collection('bookings').update(
                          booking.id,
                          body: {'status': value},
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value == 'approved' ? 'تم قبول الحجز' : 'تم رفض الحجز',
                            ),
                          ),
                        );
                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('حدث خطأ أثناء التحديث: $e')),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'approved', child: Text('قبول')),
                      PopupMenuItem(value: 'rejected', child: Text('رفض')),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
        return 'قيد الانتظار';
      default:
        return status;
    }
  }
}
