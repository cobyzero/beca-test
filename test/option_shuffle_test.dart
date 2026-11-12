import 'dart:math';

import 'package:beca_test/data/repositories/exam_repository.dart';
import 'package:beca_test/data/repositories/in_memory_progress_repository.dart';
import 'package:beca_test/domain/models/question.dart';
import 'package:beca_test/presentation/controllers/study_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Desorden de alternativas (Option Shuffling)', () {
    test('withShuffledOptions asigna letras a, b, c, d correlativas y actualiza la clave', () {
      final question = Question(
        id: '2025-q1',
        year: 2025,
        number: 1,
        area: ExamArea.matematicas,
        prompt: 'Pregunta de prueba',
        options: const [
          AnswerOption(id: 'a', text: 'Opción Uno'),
          AnswerOption(id: 'b', text: 'Opción Dos'),
          AnswerOption(id: 'c', text: 'Opción Tres (Correcta)'),
          AnswerOption(id: 'd', text: 'Opción Cuatro'),
        ],
        correctOptionId: 'c',
        studyTopic: const StudyTopic(
          title: 'Tema Prueba',
          mechanism: 'Mecanismo con alternativa c como resultado.',
          analogy: 'Analogía',
          keyPoints: ['Punto 1'],
          workedExample: WorkedExample(
            prompt: 'Ejemplo',
            steps: ['Paso 1'],
            result: 'Resultado',
          ),
          examSolutionSteps: [
            '1. Paso inicial.',
            '2. Total obtenido (alternativa c).',
          ],
        ),
      );

      // Usamos una semilla que garantice un reordenamiento donde 'c' no quede en el slot 2 ('c')
      final shuffled = question.withShuffledOptions(Random(12345));

      // Las opciones en pantalla siempre son correlativas: a, b, c, d
      expect(shuffled.options.map((o) => o.id).toList(), ['a', 'b', 'c', 'd']);

      // Cada opción retiene su originalId intacto
      expect(shuffled.options.every((o) => ['a', 'b', 'c', 'd'].contains(o.originalId)), isTrue);

      // La opción marcada como correcta tiene el texto que antes era la alternativa 'c'
      final correctOpt = shuffled.options.firstWhere((o) => o.id == shuffled.correctOptionId);
      expect(correctOpt.text, 'Opción Tres (Correcta)');
      expect(correctOpt.originalId, 'c');

      // La explicación del examen menciona la nueva letra de la clave
      expect(
        shuffled.studyTopic.examSolutionSteps.last,
        contains('alternativa ${shuffled.correctOptionId})'),
      );
    });

    test('StudyController persiste respuestas por originalId y las restaura correctamente tras reshuffle', () async {
      final repository = AssetExamRepository();
      final progressRepo = InMemoryProgressRepository();

      // Cargar primera sesión para "Maria"
      final controller1 = StudyController(
        repository: repository,
        progressRepository: progressRepo,
        studentName: 'Maria',
        yearFilter: 2025,
      );

      await controller1.load();
      expect(controller1.hasQuestions, isTrue);

      final q1 = controller1.currentQuestion;
      // Seleccionar la opción correcta en la posición que haya quedado
      controller1.goToExamPhase();
      controller1.selectOption(q1.correctOptionId);
      controller1.verifyAnswer();

      expect(controller1.isCurrentAnswerCorrect, isTrue);
      expect(controller1.score, 1);

      // Simular una nueva sesión o recarga de página (nuevo controlador con nuevo orden aleatorio)
      final controller2 = StudyController(
        repository: repository,
        progressRepository: progressRepo,
        studentName: 'Maria',
        yearFilter: 2025,
      );

      await controller2.load();

      // Debe haber restaurado la respuesta y el puntaje
      expect(controller2.score, 1);
      expect(controller2.isVerified, isTrue);
      expect(controller2.isCurrentAnswerCorrect, isTrue);

      // La opción seleccionada en controller2 debe ser la que tiene originalId == 'c' (clave original de Q1)
      final selectedOpt = controller2.currentQuestion.options.firstWhere(
        (o) => o.id == controller2.selectedOptionId,
      );
      expect(selectedOpt.originalId, q1.originalCorrectOptionId);
    });
  });
}
