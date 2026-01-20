import 'package:flutter/material.dart';


import '../pdf_manager_libs.dart';

class PDFViewerScreen extends StatefulWidget {
  const PDFViewerScreen({super.key,required this.link});
  final String link;
  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  static const Color _navyColor = Color(0xFF001F54);

  late final PDFManager _pdfManager;
  late final QuestionManager _questionManager;
  late PageChangeController _pageChangeController;

  final TextEditingController _urlController = TextEditingController();
  PdfController? _pdfController;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    
    _pdfManager = PDFManager();
    _questionManager = QuestionManager();
    _pageChangeController = PageChangeController(
      questionManager: _questionManager,
      onPageChanged: (_) => setState(() {}),
      onError: (error) => SnackBarService.showError(context, error),
    );
    _handleLoadFromUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _pdfController?.dispose();
    _pageChangeController.dispose();
    super.dispose();
  }

  Future<void> _handlePickFile() async {
    if (await _pdfManager.pickPDF()) _initializePdf();
  }

  void _handleLoadFromUrl() {
    final url = widget.link;
    if (url.isEmpty) {
      SnackBarService.showWarning(context, 'Please enter a valid URL');
      return;
    }
    _pdfManager.loadFromUrl(url);
    _initializePdf();
  }

  void _initializePdf() {
    _pdfController?.dispose();
    _pdfController = PDFControllerFactory.createFromManager(
      pdfBytes: _pdfManager.pdfBytes,
      pdfUrl: _pdfManager.pdfUrl,
    );

    if (_pdfController != null) {
      _pageChangeController = PageChangeController(
        questionManager: _questionManager,
        pdfController: _pdfController,
        onPageChanged: (_) => setState(() {}),
        onError: (error) => SnackBarService.showError(context, error),
      );
      _pageChangeController.reset();
      setState(() {});
    } else {
      SnackBarService.showError(context, 'Failed to load PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer with Questions'),
        backgroundColor: _navyColor,
        foregroundColor: Colors.white,
        actions: [if (_pdfController != null) _buildProgressIndicator()],
      ),
      body: Column(
        children: [
          // _buildControls(),
          Expanded(
            child: _pdfController != null
                ? _buildPdfViewer()
                : _buildEmptyState(),
          ),
          if (_pdfController != null) _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _questionManager.getProgress();
    final answered = _questionManager.answerState.totalAnswered;
    final total = _questionManager.totalQuestions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$answered/$total',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.greenAccent,
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextField(
          //         controller: _urlController,
          //         decoration: const InputDecoration(
          //           hintText: 'Enter PDF URL',
          //           border: OutlineInputBorder(),
          //           contentPadding: EdgeInsets.symmetric(
          //             horizontal: 12,
          //             vertical: 8,
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     ElevatedButton(
          //       onPressed: _handleLoadFromUrl,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: _navyColor,
          //         foregroundColor: Colors.white,
          //       ),
          //       child: const Text('Load'),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handlePickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick PDF File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navyColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    return PdfView(
      controller: _pdfController!,
      onPageChanged: (page) => _pageChangeController.handlePageChange(
        context: context,
        newPage: page,
      ),
      onDocumentLoaded: (doc) {
        setState(() {
          _totalPages = doc.pagesCount;
          // Optional: Auto-add questions for specific pages
          // _questionManager.addQuestionsForEvenPages(_totalPages);
        });
      },
      scrollDirection: Axis.vertical,
    );
  }

  Widget _buildNavigationBar() {
    final currentPage = _pageChangeController.currentPage;
    final canGoBack = currentPage > 1;
    final canGoForward =
        currentPage < _totalPages &&
        _questionManager.canNavigateToPage(currentPage + 1, currentPage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Page $currentPage of $_totalPages',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_questionManager.totalQuestions > 0) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _navyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_questionManager.answerState.totalAnswered}/${_questionManager.totalQuestions} answered',
                    style: TextStyle(
                      fontSize: 12,
                      color: _navyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Pagination
          PDFPagination(
            currentPage: currentPage,
            totalPages: _totalPages,
            canGoBack: canGoBack,
            canGoForward: canGoForward,
            onPrevious: _pageChangeController.goToPreviousPage,
            onNext: _pageChangeController.goToNextPage,
            onPageTap: _handlePageNumberClick,
            hasQuestion: _questionManager.hasQuestion,
            isAnswered: _questionManager.answerState.isPageAnswered,
            primaryColor: _navyColor,
            limitAppear: 6,
          ),
        ],
      ),
    );
  }

  void _handlePageNumberClick(int targetPage) {
    if (targetPage == _pageChangeController.currentPage) return;

    if (!_questionManager.canNavigateToPage(
      targetPage,
      _pageChangeController.currentPage,
    )) {
      SnackBarService.showWarning(
        context,
        'Please answer the current page question first!',
      );
      return;
    }

    _pageChangeController.goToPage(targetPage);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No PDF Loaded',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a file or load from URL',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
