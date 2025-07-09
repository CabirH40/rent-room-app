import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../property/presentation/property_detail_page.dart';

class PropertyTile extends StatelessWidget {
  final RecordModel property;

  const PropertyTile({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final data = property.data;
    final images = property.getListValue('images');
    final title = data['title'] ?? 'بدون عنوان';
    final address = data['address'] ?? '';
    final price = data['pricePerNight']?.toString() ?? '';

    Widget leadingWidget;

    if (images.isNotEmpty) {
      leadingWidget = SizedBox(
        width: 80,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'http://152.53.84.199:8090/api/files/${property.collectionId}/${property.id}/${images[0]}',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      leadingWidget = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.home, size: 40, color: Colors.grey),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: leadingWidget,
        title: Text(title),
        subtitle: Text('$address\n$price ليرة/ليلة'),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailPage(propertyId: property.id),
            ),
          );
        },
      ),
    );
  }
}
