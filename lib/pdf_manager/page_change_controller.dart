import 'package:flutter/material.dart';

import '../pdf_manager_libs.dart';

class PageChangeController {
  final QuestionManager questionManager;
  final PdfController? pdfController;
  final Function(int)? onPageChanged;
  final Function(String)? onError;

  int _currentPage = 1;
  bool _isProcessing = false;

  PageChangeController({
    required this.questionManager,
    this.pdfController,
    this.onPageChanged,
    this.onError,
  });

  int get currentPage => _currentPage;

  bool get isProcessing => _isProcessing;

  Future<void> handlePageChange({
    required BuildContext context,
    required int newPage,
  }) async {
    if (_isProcessing || newPage == _currentPage) return;

    // Check if navigation is allowed
    if (!questionManager.canNavigateToPage(newPage, _currentPage)) {
      _showWarning(
        context,
        'Please answer the question on page $_currentPage before moving forward!',
      );
      await _revertToCurrentPage();
      return;
    }

    _isProcessing = true;

    try {
      // Show question dialog if new page has a question
      final shouldProceed = await questionManager.showQuestionDialog(
        context: context,
        pageNumber: newPage,
      );

      if (shouldProceed) {
        _currentPage = newPage;
        onPageChanged?.call(newPage);
      } else {
        await _revertToCurrentPage();
      }
    } catch (e) {
      onError?.call('Error changing page: $e');
      await _revertToCurrentPage();
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _revertToCurrentPage() async {
    await pdfController?.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void goToNextPage() => pdfController?.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.ease,
  );

  void goToPreviousPage() => pdfController?.previousPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.ease,
  );

  void goToPage(int number) => pdfController?.jumpToPage(number);

  void updateCurrentPage(int page) => _currentPage = page;

  void reset() {
    _currentPage = 1;
    _isProcessing = false;
    questionManager.clearAllAnswers();
  }

  void dispose() {}
}
