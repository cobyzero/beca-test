import 'dart:math';

/// Áreas evaluadas en el examen de selección Beca 18 (PRONABEC).
enum ExamArea {
  matematicas('Competencias Matemáticas'),
  lectura('Competencia Lectora');

  const ExamArea(this.label);

  /// Nombre legible del área para mostrar en la interfaz.
  final String label;

  static ExamArea fromJson(String value) {
    return ExamArea.values.firstWhere(
      (area) => area.name == value,
      orElse: () => throw FormatException('Área de examen desconocida: $value'),
    );
  }
}

/// Fases de estudio por cada pregunta.
enum StudyPhase {
  concept,
  exam,
}

/// Alternativa de respuesta de una pregunta de opción múltiple.
class AnswerOption {
  const AnswerOption({
    required this.id,
    required this.text,
    String? originalId,
    this.imageAsset,
    this.imageAlt,
  }) : originalId = originalId ?? id;

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return AnswerOption(
      id: id,
      originalId: (json['originalId'] as String?) ?? id,
      text: json['text'] as String,
      imageAsset: json['imageAsset'] as String?,
      imageAlt: json['imageAlt'] as String?,
    );
  }

  /// Identificador visible de la alternativa ('a', 'b', 'c', 'd').
  final String id;

  /// Identificador original de la alternativa en el examen oficial.
  final String originalId;

  /// Texto de la alternativa.
  final String text;

  /// Imagen opcional de la alternativa (ruta de asset).
  final String? imageAsset;

  /// Descripción accesible de la imagen de la alternativa.
  final String? imageAlt;
}

/// Ejercicio resuelto con otros datos para ilustrar el concepto antes del examen.
class WorkedExample {
  const WorkedExample({
    required this.prompt,
    required this.steps,
    required this.result,
    this.imageAsset,
    this.imageAlt,
  });

  factory WorkedExample.fromJson(Map<String, dynamic> json) {
    return WorkedExample(
      prompt: json['prompt'] as String,
      steps: List<String>.from(json['steps'] as List<dynamic>),
      result: json['result'] as String,
      imageAsset: json['imageAsset'] as String?,
      imageAlt: json['imageAlt'] as String?,
    );
  }

  final String prompt;
  final List<String> steps;
  final String result;
  final String? imageAsset;
  final String? imageAlt;
}

/// Tema de estudio asociado a una pregunta (enfoque Feynman + ejemplo similar).
class StudyTopic {
  const StudyTopic({
    required this.title,
    required this.mechanism,
    required this.analogy,
    required this.keyPoints,
    required this.workedExample,
    required this.examSolutionSteps,
  });

  factory StudyTopic.fromJson(Map<String, dynamic> json) {
    return StudyTopic(
      title: json['title'] as String,
      mechanism: json['mechanism'] as String,
      analogy: json['analogy'] as String,
      keyPoints: List<String>.from(json['keyPoints'] as List<dynamic>),
      workedExample: WorkedExample.fromJson(
        json['workedExample'] as Map<String, dynamic>,
      ),
      examSolutionSteps: List<String>.from(
        json['examSolutionSteps'] as List<dynamic>,
      ),
    );
  }

  /// Nombre del tema (presentado después de entender el mecanismo).
  final String title;

  /// Explicación del mecanismo real antes de la jerga técnica.
  final String mechanism;

  /// Analogía cotidiana con su límite explícito.
  final String analogy;

  /// Reglas o ideas clave para recordar.
  final List<String> keyPoints;

  /// Ejercicio similar con otros datos y su desarrollo.
  final WorkedExample workedExample;

  /// Desarrollo paso a paso de la pregunta oficial del examen.
  final List<String> examSolutionSteps;
}

/// Pregunta de examen con su tema de estudio en dos fases.
class Question {
  const Question({
    required this.id,
    required this.year,
    required this.number,
    required this.area,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.studyTopic,
    String? originalCorrectOptionId,
    this.imageAsset,
    this.imageAlt,
    this.readingPassage,
  }) : originalCorrectOptionId = originalCorrectOptionId ?? correctOptionId;

  factory Question.fromJson(Map<String, dynamic> json) {
    final correctId = json['correctOptionId'] as String;
    return Question(
      id: json['id'] as String,
      year: json['year'] as int,
      number: json['number'] as int,
      area: ExamArea.fromJson(json['area'] as String),
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>)
          .map((item) => AnswerOption.fromJson(item as Map<String, dynamic>))
          .toList(),
      correctOptionId: correctId,
      originalCorrectOptionId:
          (json['originalCorrectOptionId'] as String?) ?? correctId,
      studyTopic: StudyTopic.fromJson(
        json['studyTopic'] as Map<String, dynamic>,
      ),
      imageAsset: json['imageAsset'] as String?,
      imageAlt: json['imageAlt'] as String?,
      readingPassage: json['readingPassage'] as String?,
    );
  }

  final String id;
  final int year;
  final int number;
  final ExamArea area;
  final String prompt;
  final List<AnswerOption> options;
  final String correctOptionId;
  final String originalCorrectOptionId;
  final StudyTopic studyTopic;

  /// Imagen opcional del enunciado (ruta de asset).
  final String? imageAsset;

  /// Descripción accesible de la imagen del enunciado.
  final String? imageAlt;

  /// Texto de lectura asociado (para preguntas de Competencia Lectora).
  final String? readingPassage;

  bool isCorrect(String? selectedOptionId) =>
      selectedOptionId != null && selectedOptionId == correctOptionId;

  /// Retorna una copia de la pregunta con las alternativas desordenadas de forma aleatoria,
  /// reasignando correlativamente las letras 'a', 'b', 'c', 'd' a las opciones y
  /// actualizando tanto la clave correcta como sus menciones en la resolución paso a paso.
  Question withShuffledOptions([Random? random]) {
    final rng = random ?? Random();
    final shuffled = List<AnswerOption>.from(options)..shuffle(rng);

    const slotLetters = ['a', 'b', 'c', 'd'];
    final newOptions = <AnswerOption>[];
    final letterMap = <String, String>{};
    var newCorrectId = correctOptionId;

    for (var i = 0; i < shuffled.length; i++) {
      final slotLetter = i < slotLetters.length
          ? slotLetters[i]
          : String.fromCharCode(97 + i);
      final opt = shuffled[i];
      letterMap[opt.originalId] = slotLetter;
      if (opt.originalId == originalCorrectOptionId) {
        newCorrectId = slotLetter;
      }
      newOptions.add(AnswerOption(
        id: slotLetter,
        originalId: opt.originalId,
        text: opt.text,
        imageAsset: opt.imageAsset,
        imageAlt: opt.imageAlt,
      ));
    }

    final updatedSteps = studyTopic.examSolutionSteps.map((step) {
      return _replaceOptionReferences(step, letterMap);
    }).toList();

    final updatedMechanism = _replaceOptionReferences(
      studyTopic.mechanism,
      letterMap,
    );

    final updatedTopic = StudyTopic(
      title: studyTopic.title,
      mechanism: updatedMechanism,
      analogy: studyTopic.analogy,
      keyPoints: studyTopic.keyPoints,
      workedExample: studyTopic.workedExample,
      examSolutionSteps: updatedSteps,
    );

    return Question(
      id: id,
      year: year,
      number: number,
      area: area,
      prompt: prompt,
      options: newOptions,
      correctOptionId: newCorrectId,
      originalCorrectOptionId: originalCorrectOptionId,
      studyTopic: updatedTopic,
      imageAsset: imageAsset,
      imageAlt: imageAlt,
      readingPassage: readingPassage,
    );
  }

  static String _replaceOptionReferences(
    String text,
    Map<String, String> originalToNewMap,
  ) {
    var result = text;
    for (final entry in originalToNewMap.entries) {
      final oldLetter = entry.key;
      final newLetter = entry.value;
      final placeholder = '@@@_OPT_${newLetter}_@@@';
      final pattern = RegExp(
        r'(\b(?:alternativa|opción|afirmación|clave|verifica|descarta)\s*\(?)' +
            oldLetter +
            r'(\)?[\.\:\,\)]?|\b)',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(pattern, (match) {
        return '${match.group(1)}$placeholder${match.group(2)}';
      });
    }

    for (final newLetter in originalToNewMap.values) {
      result = result.replaceAll('@@@_OPT_${newLetter}_@@@', newLetter);
    }
    return result;
  }
}
