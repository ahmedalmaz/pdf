// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdf_web/pdf_manager/pdf_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer with Questions',
      theme: ThemeData(
        primaryColor: const Color(0xFF001F54),
        useMaterial3: true,
      ),
      home: const PDFViewerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
