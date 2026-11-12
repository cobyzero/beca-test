import 'package:flutter/foundation.dart';

import '../../data/repositories/exam_repository.dart';
import '../../domain/models/question.dart';

/// Controlador de estado para el flujo de estudio en dos fases y puntaje.
class StudyController extends ChangeNotifier {
  StudyController({required this.repository, this.yearFilter});

  final ExamRepository repository;
  final int? yearFilter;

  List<Question> _questions = const [];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;
  StudyPhase _currentPhase = StudyPhase.concept;
  bool _isExamFinished = false;
  final Map<String, String> _selectedOptions = {};
  final Set<String> _verifiedQuestionIds = {};
  final Set<String> _revealedExampleIds = {};

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasQuestions => _questions.isNotEmpty;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  Question get currentQuestion => _questions[_currentIndex];

  StudyPhase get currentPhase => _currentPhase;
  bool get isExamFinished => _isExamFinished;
  bool get isLastQuestion =>
      hasQuestions && _currentIndex == _questions.length - 1;

  bool get showWorkedExampleSolution =>
      hasQuestions && _revealedExampleIds.contains(currentQuestion.id);

  String? get selectedOptionId =>
      hasQuestions ? _selectedOptions[currentQuestion.id] : null;

  bool get isVerified =>
      hasQuestions && _verifiedQuestionIds.contains(currentQuestion.id);

  bool get isCurrentAnswerCorrect =>
      isVerified && currentQuestion.isCorrect(selectedOptionId);

  /// Puntaje total acumulado: 1 punto por cada pregunta respondida correctamente.
  int get score {
    var total = 0;
    for (final question in _questions) {
      if (_verifiedQuestionIds.contains(question.id) &&
          question.isCorrect(_selectedOptions[question.id])) {
        total++;
      }
    }
    return total;
  }

  bool get canGoPrevious => _currentIndex > 0;
  bool get canGoNext => _currentIndex < _questions.length - 1;

  /// Carga las clases y preguntas desde el JSON al iniciar la aplicación.
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await repository.loadQuestions(year: yearFilter);
      _currentIndex = 0;
      _currentPhase = StudyPhase.concept;
      _isExamFinished = false;
      _selectedOptions.clear();
      _verifiedQuestionIds.clear();
      _revealedExampleIds.clear();
    } catch (error) {
      _errorMessage = 'No se pudieron cargar las clases: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPhase(StudyPhase phase) {
    if (_currentPhase == phase) return;
    _currentPhase = phase;
    notifyListeners();
  }

  void goToExamPhase() => setPhase(StudyPhase.exam);

  void goToConceptPhase() => setPhase(StudyPhase.concept);

  void toggleWorkedExampleSolution() {
    if (!hasQuestions) return;
    final id = currentQuestion.id;
    if (_revealedExampleIds.contains(id)) {
      _revealedExampleIds.remove(id);
    } else {
      _revealedExampleIds.add(id);
    }
    notifyListeners();
  }

  void selectOption(String optionId) {
    if (!hasQuestions || isVerified) return;
    _selectedOptions[currentQuestion.id] = optionId;
    notifyListeners();
  }

  void verifyAnswer() {
    if (!hasQuestions || selectedOptionId == null || isVerified) return;
    _verifiedQuestionIds.add(currentQuestion.id);
    notifyListeners();
  }

  void finishExam() {
    if (!hasQuestions) return;
    _isExamFinished = true;
    notifyListeners();
  }

  void reviewExam() {
    _isExamFinished = false;
    _currentPhase = StudyPhase.exam;
    notifyListeners();
  }

  void nextQuestion() {
    if (!canGoNext) return;
    _currentIndex++;
    _currentPhase = StudyPhase.concept;
    notifyListeners();
  }

  void previousQuestion() {
    if (!canGoPrevious) return;
    _currentIndex--;
    _currentPhase = StudyPhase.concept;
    notifyListeners();
  }

  void jumpToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    _currentIndex = index;
    _currentPhase = StudyPhase.concept;
    _isExamFinished = false;
    notifyListeners();
  }
}
