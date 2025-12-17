import 'package:flutter/foundation.dart';
import 'package:internet_file/internet_file.dart';
import '../pdf_manager_libs.dart';

class PDFControllerFactory {
  static PdfController? createFromBytes(Uint8List bytes) {
    try {
      return PdfController(document: PdfDocument.openData(bytes));
    } catch (e) {
      debugPrint('Error creating PDF controller from bytes: $e');
      return null;
    }
  }

  static PdfController? createFromUrl(String url) {
    try {
      return PdfController(
        document: PdfDocument.openData(InternetFile.get(url)),
      );
    } catch (e) {
      debugPrint('Error creating PDF controller from URL: $e');
      return null;
    }
  }

  static PdfController? createFromManager({
    Uint8List? pdfBytes,
    String? pdfUrl,
  }) {
    if (pdfBytes != null) {
      return createFromBytes(pdfBytes);
    } else if (pdfUrl != null) {
      return createFromUrl(pdfUrl);
    }
    return null;
  }
}
