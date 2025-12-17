import 'package:flutter/material.dart';

class PDFPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Function(int) onPageTap;
  final bool Function(int)? hasQuestion;
  final bool Function(int)? isAnswered;
  final Color primaryColor;
  final int limitAppear;

  const PDFPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
    required this.onPageTap,
    this.hasQuestion,
    this.isAnswered,
    this.primaryColor = const Color(0xFF001F54),
    this.limitAppear = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPreviousButton(),
        const SizedBox(width: 12),
        Flexible(child: _buildPageNumbers()),
        const SizedBox(width: 12),
        _buildNextButton(),
      ],
    );
  }

  Widget _buildPreviousButton() {
    return OutlinedButton.icon(
      onPressed: canGoBack ? onPrevious : null,
      icon: const Icon(Icons.chevron_left, size: 20),
      label: const Text('Previous'),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        disabledForegroundColor: Colors.grey[400],
        side: BorderSide(
          color: canGoBack ? primaryColor : Colors.grey[300]!,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNextButton() {
    return OutlinedButton.icon(
      onPressed: canGoForward ? onNext : null,
      label: const Text('Next'),
      icon: const Icon(Icons.chevron_right, size: 20),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        disabledForegroundColor: Colors.grey[400],
        side: BorderSide(
          color: canGoForward ? primaryColor : Colors.grey[300]!,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPageNumbers() {
    final pageNumbers = _generatePageNumbers();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: pageNumbers.map((pageNum) {
          if (pageNum == -1) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return _buildPageButton(pageNum);
        }).toList(),
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == currentPage;
    final hasQ = hasQuestion?.call(pageNumber) ?? false;
    final isAns = isAnswered?.call(pageNumber) ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: isCurrentPage ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => onPageTap(pageNumber),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCurrentPage ? primaryColor : Colors.grey[300]!,
                    width: isCurrentPage ? 2 : 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrentPage
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isCurrentPage ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasQ)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isAns ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  isAns ? Icons.check : Icons.circle,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<int> _generatePageNumbers() {
    if (totalPages <= 10) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final List<int> pages = [1];

    if (currentPage > limitAppear) pages.add(-1);

    for (
      int i = currentPage - (limitAppear / 2).ceil();
      i <= currentPage + (limitAppear / 2).ceil();
      i++
    ) {
      if (i > 1 && i < totalPages) pages.add(i);
    }

    if (currentPage < totalPages - (limitAppear - 1)) pages.add(-1);

    if (!pages.contains(totalPages)) pages.add(totalPages);

    return pages;
  }
}
