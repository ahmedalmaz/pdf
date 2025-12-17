class AnswerState {
  final Map<int, String> _answers = {};

  bool isPageAnswered(int page) => _answers.containsKey(page);

  String? getAnswer(int page) => _answers[page];

  void setAnswer(int page, String answer) {
    _answers[page] = answer;
  }

  void removeAnswer(int page) {
    _answers.remove(page);
  }

  void clear() {
    _answers.clear();
  }

  int get totalAnswered => _answers.length;

  List<int> get answeredPages => _answers.keys.toList()..sort();
}

