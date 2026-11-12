import 'package:flutter/foundation.dart';

import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/question.dart';
import '../../domain/models/student_progress.dart';

/// Controlador de estado para el flujo de estudio en dos fases, puntaje y persistencia.
class StudyController extends ChangeNotifier {
  StudyController({
    required this.repository,
    this.progressRepository,
    this.studentName,
    this.yearFilter,
  });

  final ExamRepository repository;
  final ProgressRepository? progressRepository;
  String? studentName;
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

  /// Cambia de estudiante activo y recarga su progreso.
  Future<void> changeStudent(String newStudentName) async {
    studentName = newStudentName.trim();
    await load();
  }

  /// Carga las preguntas y restaura el progreso persistido si existe.
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedQuestions = await repository.loadQuestions(year: yearFilter);
      _questions = loadedQuestions.map((q) => q.withShuffledOptions()).toList();
      _currentIndex = 0;
      _currentPhase = StudyPhase.concept;
      _isExamFinished = false;
      _selectedOptions.clear();
      _verifiedQuestionIds.clear();
      _revealedExampleIds.clear();

      // Restaurar progreso si hay repositorio y estudiante asignado
      if (progressRepository != null &&
          studentName != null &&
          studentName!.trim().isNotEmpty) {
        final year = yearFilter ?? 2025;
        final saved = await progressRepository!.getProgress(
          studentName: studentName!,
          year: year,
        );

        if (saved != null && _questions.isNotEmpty) {
          _currentIndex = saved.currentIndex.clamp(0, _questions.length - 1);
          _currentPhase = saved.currentPhase;
          _isExamFinished = saved.isCompleted;

          // Mapeamos las respuestas guardadas (identificadas por originalId)
          // a la ranura visual actual ('a', 'b', 'c', 'd') de la pregunta desordenada.
          for (final entry in saved.answers.entries) {
            final questionId = entry.key;
            final savedOriginalId = entry.value;
            final q = _questions.cast<Question?>().firstWhere(
              (item) => item?.id == questionId,
              orElse: () => null,
            );
            if (q != null) {
              final matchedOption = q.options.cast<AnswerOption?>().firstWhere(
                (opt) => opt?.originalId == savedOriginalId,
                orElse: () => null,
              );
              _selectedOptions[questionId] =
                  matchedOption?.id ?? savedOriginalId;
            } else {
              _selectedOptions[questionId] = savedOriginalId;
            }
          }

          _verifiedQuestionIds.addAll(saved.verifiedQuestionIds);
        }
      }
    } catch (error) {
      _errorMessage = 'No se pudieron cargar las clases: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    if (progressRepository == null ||
        studentName == null ||
        studentName!.trim().isEmpty) {
      return;
    }

    final year = yearFilter ?? 2025;

    // Convertimos la ranura visual seleccionada ('a', 'b', ...) al originalId
    // para que la respuesta elegida sea inmune a futuros desórdenes aleatorios.
    final persistentAnswers = <String, String>{};
    for (final entry in _selectedOptions.entries) {
      final questionId = entry.key;
      final selectedSlotId = entry.value;
      final q = _questions.cast<Question?>().firstWhere(
        (item) => item?.id == questionId,
        orElse: () => null,
      );
      if (q != null) {
        final opt = q.options.cast<AnswerOption?>().firstWhere(
          (o) => o?.id == selectedSlotId,
          orElse: () => null,
        );
        persistentAnswers[questionId] = opt?.originalId ?? selectedSlotId;
      } else {
        persistentAnswers[questionId] = selectedSlotId;
      }
    }

    final progress = ExamProgress(
      studentName: studentName!,
      year: year,
      currentIndex: _currentIndex,
      currentPhase: _currentPhase,
      answers: persistentAnswers,
      verifiedQuestionIds: Set<String>.from(_verifiedQuestionIds),
      score: score,
      isCompleted: _isExamFinished,
      updatedAt: DateTime.now(),
    );

    await progressRepository!.saveProgress(progress);
  }

  /// Reinicia el progreso del estudiante en este examen desde cero y vuelve a desordenar las opciones.
  Future<void> resetProgress() async {
    _questions = _questions.map((q) => q.withShuffledOptions()).toList();
    _currentIndex = 0;
    _currentPhase = StudyPhase.concept;
    _isExamFinished = false;
    _selectedOptions.clear();
    _verifiedQuestionIds.clear();
    _revealedExampleIds.clear();

    if (progressRepository != null &&
        studentName != null &&
        studentName!.trim().isNotEmpty) {
      await progressRepository!.clearProgress(
        studentName: studentName!,
        year: yearFilter ?? 2025,
      );
    }

    notifyListeners();
  }

  void setPhase(StudyPhase phase) {
    if (_currentPhase == phase) return;
    _currentPhase = phase;
    notifyListeners();
    _persist();
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
    _persist();
  }

  void verifyAnswer() {
    if (!hasQuestions || selectedOptionId == null || isVerified) return;
    _verifiedQuestionIds.add(currentQuestion.id);
    notifyListeners();
    _persist();
  }

  void finishExam() {
    if (!hasQuestions) return;
    _isExamFinished = true;
    notifyListeners();
    _persist();
  }

  void reviewExam() {
    _isExamFinished = false;
    _currentPhase = StudyPhase.exam;
    notifyListeners();
    _persist();
  }

  void nextQuestion() {
    if (!canGoNext) return;
    _currentIndex++;
    _currentPhase = StudyPhase.concept;
    notifyListeners();
    _persist();
  }

  void previousQuestion() {
    if (!canGoPrevious) return;
    _currentIndex--;
    _currentPhase = StudyPhase.concept;
    notifyListeners();
    _persist();
  }

  void jumpToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    _currentIndex = index;
    _currentPhase = StudyPhase.concept;
    _isExamFinished = false;
    notifyListeners();
    _persist();
  }
}
