import 'package:flutter/material.dart';

class RentRoomApp extends StatelessWidget {
  const RentRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Room',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const Scaffold(body: Center(child: Text('Rent Room App جاهز'))),
    );
  }
}
