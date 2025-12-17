import 'package:flutter/material.dart';

import '../../models/answer_state.dart';
import '../../models/question_model.dart';
import '../widgets/question_dialog.dart';

class QuestionManager {
  final AnswerState answerState = AnswerState();

  // Define which pages have questions
  final Map<int, QuestionModel> _pageQuestions = {};

  QuestionManager() {
    _initializeQuestions();
  }

  // Configure which pages have questions
  void _initializeQuestions() {
    // Example: Only pages 2, 5, 7 have questions
    _pageQuestions[2] = const QuestionModel(
      pageNumber: 2,
      question: "ما هو حرف الدرس في الصفحة الثانية؟",
      options: ["دال", "راء", "زاي", "سين"],
    );

    _pageQuestions[5] = const QuestionModel(
      pageNumber: 5,
      question: "ما هو حرف الدرس في الصفحة الخامسة؟",
      options: ["ألف", "باء", "تاء", "ثاء"],
    );

    _pageQuestions[7] = const QuestionModel(
      pageNumber: 7,
      question: "ما هو حرف الدرس في الصفحة السابعة؟",
      options: ["جيم", "حاء", "خاء", "دال"],
    );
  }

  void addQuestion(QuestionModel question) {
    _pageQuestions[question.pageNumber] = question;
  }

  void addQuestionsForEvenPages(int totalPages) {
    for (int i = 2; i <= totalPages; i += 2) {
      _pageQuestions[i] = QuestionModel(
        pageNumber: i,
        question: "هل انتهيت من قراءة الصفحة $i؟",
        options: ["نعم، فهمت المحتوى", "نعم، لكن أحتاج مراجعة", "لا، لم أنتهي"],
      );
    }
  }

  bool hasQuestion(int pageNumber) {
    return _pageQuestions.containsKey(pageNumber);
  }

  QuestionModel? getQuestionForPage(int pageNumber) {
    return _pageQuestions[pageNumber];
  }

  Future<bool> showQuestionDialog({
    required BuildContext context,
    required int pageNumber,
  }) async {
    // No question for this page, allow navigation
    if (!hasQuestion(pageNumber)) {
      return true;
    }

    // Already answered, allow navigation
    if (answerState.isPageAnswered(pageNumber)) {
      return true;
    }

    final question = getQuestionForPage(pageNumber)!;

    final answer = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuestionDialog(question: question),
    );

    if (answer != null && answer.isNotEmpty) {
      answerState.setAnswer(pageNumber, answer);
      return true;
    }

    return false;
  }

  // Strict sequential validation
  bool canNavigateToPage(int targetPage, int currentPage) {
    // Can always go back
    if (targetPage <= currentPage) return true;

    // Get all pages with questions before target page
    final previousPagesWithQuestions =
        _pageQuestions.keys.where((page) => page < targetPage).toList()..sort();

    // Check if ALL previous questions are answered
    for (final page in previousPagesWithQuestions) {
      if (!answerState.isPageAnswered(page)) {
        return false; // Found an unanswered question, block navigation
      }
    }

    return true; // All previous questions answered
  }

  // Get the first unanswered question before target page
  int? getFirstUnansweredPageBefore(int targetPage) {
    final previousPagesWithQuestions =
        _pageQuestions.keys
            .where(
              (page) => page < targetPage && !answerState.isPageAnswered(page),
            )
            .toList()
          ..sort();

    return previousPagesWithQuestions.isEmpty
        ? null
        : previousPagesWithQuestions.first;
  }

  // Get all unanswered pages before target
  List<int> getAllUnansweredPagesBefore(int targetPage) {
    return _pageQuestions.keys
        .where((page) => page < targetPage && !answerState.isPageAnswered(page))
        .toList()
      ..sort();
  }

  List<int> getPagesWithQuestions() {
    return _pageQuestions.keys.toList()..sort();
  }

  List<int> getUnansweredPages() {
    return _pageQuestions.keys
        .where((page) => !answerState.isPageAnswered(page))
        .toList()
      ..sort();
  }

  double getProgress() {
    if (_pageQuestions.isEmpty) return 1.0;
    return answerState.totalAnswered / _pageQuestions.length;
  }

  int get totalQuestions => _pageQuestions.length;

  void clearAllAnswers() {
    answerState.clear();
  }
}
