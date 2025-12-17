import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class PDFManager {
  Uint8List? _pdfBytes;
  String? _pdfUrl;

  Uint8List? get pdfBytes => _pdfBytes;

  String? get pdfUrl => _pdfUrl;

  bool get hasPDF => _pdfBytes != null || _pdfUrl != null;

  bool get isFromBytes => _pdfBytes != null;

  Future<bool> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Always load bytes
      );

      if (result != null && result.files.single.bytes != null) {
        _pdfBytes = result.files.single.bytes;
        _pdfUrl = null;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      return false;
    }
  }

  void loadFromUrl(String url) {
    _pdfUrl = url;
    _pdfBytes = null;
  }

  void clear() {
    _pdfBytes = null;
    _pdfUrl = null;
  }
}
