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
    this.imageAsset,
    this.imageAlt,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as String,
      text: json['text'] as String,
      imageAsset: json['imageAsset'] as String?,
      imageAlt: json['imageAlt'] as String?,
    );
  }

  /// Identificador de la alternativa ('a', 'b', 'c', 'd').
  final String id;

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
    this.imageAsset,
    this.imageAlt,
    this.readingPassage,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      year: json['year'] as int,
      number: json['number'] as int,
      area: ExamArea.fromJson(json['area'] as String),
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>)
          .map((item) => AnswerOption.fromJson(item as Map<String, dynamic>))
          .toList(),
      correctOptionId: json['correctOptionId'] as String,
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
  final StudyTopic studyTopic;

  /// Imagen opcional del enunciado (ruta de asset).
  final String? imageAsset;

  /// Descripción accesible de la imagen del enunciado.
  final String? imageAlt;

  /// Texto de lectura asociado (para preguntas de Competencia Lectora).
  final String? readingPassage;

  bool isCorrect(String? selectedOptionId) =>
      selectedOptionId != null && selectedOptionId == correctOptionId;
}
