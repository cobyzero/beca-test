import 'package:beca_test/main.dart';
import 'package:beca_test/presentation/pages/study_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    rootBundle.clear();
  });

  Future<void> waitForAssets(WidgetTester tester) async {
    for (var i = 0;
        i < 10 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> runTwoPhaseFlow(WidgetTester tester) async {
    await tester.pumpWidget(const BecaStudyApp());
    await waitForAssets(tester);

    // Pantalla principal con listado de exámenes (solo 2025 por ahora).
    expect(find.text('Exámenes de preparación'), findsOneWidget);
    expect(find.text('Simulacro Beca 18 · 2025'), findsOneWidget);

    final startButton = find.text('Comenzar estudio');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();
    await waitForAssets(tester);

    // Fase 1: Concepto (técnica Feynman) y ejemplo similar con otros datos.
    expect(find.text('Beca 18 · Estudio'), findsOneWidget);
    expect(find.text('Puntaje: 0 / 60'), findsOneWidget);
    expect(find.text('Producto de potencias de igual base'), findsOneWidget);
    expect(find.text('Ejemplo similar (con otros datos)'), findsOneWidget);
    expect(
      find.text('Resultado del ejemplo: 2⁷ × 5⁵ lapiceros.'),
      findsNothing,
    );

    // Al presionar "Ver procedimiento y respuesta" se muestran los pasos y el resultado.
    final showSolutionButton = find.text('Ver procedimiento y respuesta');
    await tester.ensureVisible(showSolutionButton);
    await tester.tap(showSolutionButton);
    await tester.pump();
    expect(
      find.text('Resultado del ejemplo: 2⁷ × 5⁵ lapiceros.'),
      findsOneWidget,
    );

    // El indicador superior es solo visual: tocar "Examen" no cambia de fase.
    await tester.tap(find.text('Examen'));
    await tester.pump();
    expect(
      find.text('Convocatoria 2025 · Competencias Matemáticas · Pregunta 1'),
      findsNothing,
    );

    // Solo se pasa a la Fase 2 presionando "Siguiente".
    final nextButton = find.text('Siguiente');
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencias Matemáticas · Pregunta 1'),
      findsOneWidget,
    );

    // Selecciona la alternativa correcta (c) y verifica.
    final optionC = find.text('2¹² × 3⁶ pernos.');
    await tester.ensureVisible(optionC);
    await tester.tap(optionC);
    await tester.pump();

    final verifyButton = find.text('Verificar respuesta');
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pump();

    expect(
      find.text('Correcto. Revisa la resolución para confirmar el procedimiento.'),
      findsOneWidget,
    );
    expect(find.text('Resolución paso a paso'), findsOneWidget);
    expect(find.text('Puntaje: 1 / 60'), findsOneWidget);
    expect(find.text('Intentar de nuevo'), findsNothing);

    // Se puede volver atrás al concepto y al regresar al examen la respuesta sigue bloqueada.
    final backButton = find.text('Volver al concepto');
    await tester.ensureVisible(backButton);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    final returnToExam = find.text('Siguiente');
    await tester.ensureVisible(returnToExam);
    await tester.tap(returnToExam);
    await tester.pumpAndSettle();

    final optionA = find.text('2¹¹ × 3⁶ pernos.');
    await tester.ensureVisible(optionA);
    await tester.tap(optionA);
    await tester.pump();

    expect(find.text('Puntaje: 1 / 60'), findsOneWidget);
    expect(find.text('Verificar respuesta'), findsNothing);

    // Obtener controller para navegación de pruebas
    final studyPage = tester.widget<StudyPage>(find.byType(StudyPage));
    final controller = studyPage.controller;

    // Salto a la pregunta 6 (con imagen de vasos de agua y limonada).
    controller.jumpToQuestion(5);
    await tester.pumpAndSettle();

    // Pasar al examen de P6 para comprobar imagen de la pregunta.
    final nextP6 = find.text('Siguiente');
    await tester.ensureVisible(nextP6);
    await tester.tap(nextP6);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencias Matemáticas · Pregunta 6'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsWidgets);

    // Salto a la pregunta 31 (Competencia Lectora: Texto 1).
    controller.jumpToQuestion(30);
    await tester.pumpAndSettle();

    final nextP31 = find.text('Siguiente');
    await tester.ensureVisible(nextP31);
    await tester.tap(nextP31);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencia Lectora · Pregunta 31'),
      findsOneWidget,
    );
    expect(
      find.textContaining('La Desinformación en Redes Sociales'),
      findsOneWidget,
    );

    // Salto a la pregunta 60 (última pregunta del examen).
    controller.jumpToQuestion(59);
    await tester.pumpAndSettle();

    final nextP60 = find.text('Siguiente');
    await tester.ensureVisible(nextP60);
    await tester.tap(nextP60);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencia Lectora · Pregunta 60'),
      findsOneWidget,
    );

    // Verificar respuesta en P60 y probar "Ver resultado"
    final optRutinas = find.text('Establece rutinas diarias.');
    await tester.ensureVisible(optRutinas);
    await tester.tap(optRutinas);
    await tester.pump();

    final verifyP60 = find.text('Verificar respuesta');
    await tester.ensureVisible(verifyP60);
    await tester.tap(verifyP60);
    await tester.pump();

    // Como es la última pregunta (P60), aparece "Ver resultado"
    final finishButton = find.text('Ver resultado');
    await tester.ensureVisible(finishButton);
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.text('Has completado el examen'), findsOneWidget);
    expect(find.text('Puntaje obtenido'), findsOneWidget);
    expect(find.text('2 / 60'), findsAtLeastNWidgets(1));
    expect(find.text('Ver examen'), findsOneWidget);

    // "Ver examen" regresa al examen para revisar respuestas y resolución.
    final reviewExamButton = find.text('Ver examen');
    await tester.ensureVisible(reviewExamButton);
    await tester.tap(reviewExamButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencia Lectora · Pregunta 60'),
      findsOneWidget,
    );
    expect(find.text('Resolución paso a paso'), findsOneWidget);
  }

  testWidgets(
    'Flujo completo desde pantalla principal hasta resultado final (Desktop)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await runTwoPhaseFlow(tester);
    },
  );

  testWidgets(
    'Flujo completo responsive en pantalla móvil (375x812) sin desbordamientos',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await runTwoPhaseFlow(tester);
    },
  );
}
