import 'dart:convert';
import 'package:beca_test/domain/models/question.dart';

/// Perfil simple del estudiante basado en su nombre o alias.
class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.lastActiveAt,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      name: json['name'] as String,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    );
  }

  final String name;
  final DateTime lastActiveAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }
}

/// Registro persistente del progreso de un estudiante en un examen específico.
class ExamProgress {
  ExamProgress({
    required this.studentName,
    required this.year,
    required this.currentIndex,
    required this.currentPhase,
    required this.answers,
    required this.verifiedQuestionIds,
    this.score = 0,
    required this.isCompleted,
    required this.updatedAt,
  });

  factory ExamProgress.initial({
    required String studentName,
    required int year,
  }) {
    return ExamProgress(
      studentName: studentName.trim(),
      year: year,
      currentIndex: 0,
      currentPhase: StudyPhase.concept,
      answers: {},
      verifiedQuestionIds: {},
      score: 0,
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
  }

  factory ExamProgress.fromJson(Map<String, dynamic> json) {
    return ExamProgress(
      studentName: json['studentName'] as String,
      year: json['year'] as int,
      currentIndex: json['currentIndex'] as int? ?? 0,
      currentPhase: (json['currentPhase'] as String?) == 'exam'
          ? StudyPhase.exam
          : StudyPhase.concept,
      answers: (json['answers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      verifiedQuestionIds: (json['verifiedQuestionIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      score: json['score'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  final String studentName;
  final int year;
  int currentIndex;
  StudyPhase currentPhase;
  final Map<String, String> answers;
  final Set<String> verifiedQuestionIds;
  int score;
  bool isCompleted;
  DateTime updatedAt;

  int get verifiedCount => verifiedQuestionIds.length;
  int get answeredCount => answers.length;

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'year': year,
      'currentIndex': currentIndex,
      'currentPhase': currentPhase.name,
      'answers': answers,
      'verifiedQuestionIds': verifiedQuestionIds.toList(),
      'score': score,
      'isCompleted': isCompleted,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String serialize() => jsonEncode(toJson());

  static ExamProgress deserialize(String rawJson) {
    return ExamProgress.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
  }
}
