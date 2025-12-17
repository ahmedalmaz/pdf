class QuestionModel {
  final int pageNumber;
  final String question;
  final List<String> options;
  final String? correctAnswer;

  const QuestionModel({
    required this.pageNumber,
    required this.question,
    required this.options,
    this.correctAnswer,
  });
}
