import 'package:beca_test/data/repositories/exam_repository.dart';
import 'package:beca_test/domain/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Examen Convocatoria 2024 (Banco de 60 preguntas)', () {
    test('Carga exactamente 60 preguntas de 2024 con claves y temas de estudio válidos', () async {
      final repo = AssetExamRepository();
      final questions2024 = await repo.loadQuestions(year: 2024);

      expect(questions2024.length, 60);

      // 30 preguntas de matemáticas y 30 de lectura
      final math = questions2024.where((q) => q.area == ExamArea.matematicas).toList();
      final reading = questions2024.where((q) => q.area == ExamArea.lectura).toList();

      expect(math.length, 30);
      expect(reading.length, 30);

      // Claves oficiales de la página 28 del PDF oficial
      const officialKeys = {
        1: 'c', 2: 'a', 3: 'd', 4: 'd', 5: 'c', 6: 'b', 7: 'c', 8: 'c', 9: 'c', 10: 'b',
        11: 'b', 12: 'c', 13: 'd', 14: 'c', 15: 'd', 16: 'c', 17: 'd', 18: 'c', 19: 'a', 20: 'd',
        21: 'a', 22: 'c', 23: 'b', 24: 'a', 25: 'c', 26: 'c', 27: 'b', 28: 'b', 29: 'b', 30: 'c',
        31: 'd', 32: 'a', 33: 'b', 34: 'c', 35: 'b', 36: 'a', 37: 'd', 38: 'a', 39: 'b', 40: 'c',
        41: 'd', 42: 'a', 43: 'c', 44: 'b', 45: 'd', 46: 'c', 47: 'd', 48: 'c', 49: 'b', 50: 'a',
        51: 'a', 52: 'd', 53: 'c', 54: 'b', 55: 'd', 56: 'a', 57: 'c', 58: 'b', 59: 'd', 60: 'b',
      };

      for (final q in questions2024) {
        expect(q.year, 2024);
        expect(q.options.length, 4);
        expect(q.originalCorrectOptionId, officialKeys[q.number]);

        final topic = q.studyTopic;
        expect(topic.title.isNotEmpty, isTrue);
        expect(topic.mechanism.isNotEmpty, isTrue);
        expect(topic.analogy.isNotEmpty, isTrue);
        expect(topic.keyPoints.isNotEmpty, isTrue);
        expect(topic.workedExample.prompt.isNotEmpty, isTrue);
        expect(topic.workedExample.steps.isNotEmpty, isTrue);
        expect(topic.workedExample.result.isNotEmpty, isTrue);
        expect(topic.examSolutionSteps.isNotEmpty, isTrue);
      }
    });
  });
}

