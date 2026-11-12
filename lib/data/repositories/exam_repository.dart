import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/question.dart';

/// Contrato de acceso al banco de preguntas de exámenes PRONABEC.
abstract class ExamRepository {
  Future<List<Question>> loadQuestions({int? year});
}

/// Repositorio que carga las preguntas y clases desde un archivo JSON en assets.
class AssetExamRepository implements ExamRepository {
  const AssetExamRepository({
    this.assetPath = 'assets/data/questions.json',
    this.bundle,
  });

  final String assetPath;
  final AssetBundle? bundle;

  @override
  Future<List<Question>> loadQuestions({int? year}) async {
    final rawJson = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final questions = decoded
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .where((question) => year == null || question.year == year)
        .toList(growable: false);
    return List<Question>.unmodifiable(questions);
  }
}
