import 'package:beca_test/data/repositories/in_memory_progress_repository.dart';
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

  Future<void> runTwoPhaseFlow(
    WidgetTester tester, {
    required InMemoryProgressRepository progressRepo,
  }) async {
    await tester.pumpWidget(
      BecaStudyApp(
        progressRepository: progressRepo,
      ),
    );
    await waitForAssets(tester);

    // 1. Vista de Registro / Búsqueda de Estudiante
    expect(find.text('¿Quién está estudiando hoy?'), findsOneWidget);
    expect(find.text('Tu nombre o alias'), findsOneWidget);

    // Escribir nombre del estudiante
    final nameField = find.byType(TextField);
    await tester.enterText(nameField, 'Carlos');
    await tester.pumpAndSettle();

    // Como es nuevo, debe mostrar el estado correspondiente
    expect(
      find.text('Nuevo registro. Comenzarás desde la Pregunta 1.'),
      findsOneWidget,
    );

    final startStudyButton = find.text('Comenzar estudio');
    await tester.ensureVisible(startStudyButton);
    await tester.tap(startStudyButton);
    await tester.pump();
    await waitForAssets(tester);

    // 2. Pantalla principal de Exámenes
    expect(find.text('Exámenes de preparación'), findsOneWidget);
    expect(find.text('Simulacro Beca 18 · 2025'), findsOneWidget);
    expect(find.text('Simulacro Beca 18 · 2024'), findsOneWidget);
    expect(find.text('Carlos'), findsOneWidget);

    final startExamButton = find.text('Comenzar estudio').first;
    await tester.ensureVisible(startExamButton);
    await tester.tap(startExamButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await waitForAssets(tester);

    // 3. Fase 1: Concepto (técnica Feynman)
    expect(find.text('Beca 18 · Estudio'), findsOneWidget);
    expect(find.text('Puntaje: 0 / 60'), findsOneWidget);
    expect(find.text('Producto de potencias de igual base'), findsOneWidget);
    expect(find.text('Ejemplo similar (con otros datos)'), findsOneWidget);

    // Al presionar "Ver procedimiento y respuesta"
    final showSolutionButton = find.text('Ver procedimiento y respuesta');
    await tester.ensureVisible(showSolutionButton);
    await tester.tap(showSolutionButton);
    await tester.pump();
    expect(
      find.text('Resultado del ejemplo: 2⁷ × 5⁵ lapiceros.'),
      findsOneWidget,
    );

    // Pasar a Fase 2 (Examen) presionando "Siguiente"
    final nextButton = find.text('Siguiente');
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencias Matemáticas · Pregunta 1'),
      findsOneWidget,
    );

    // Seleccionar opción correcta (c) y verificar
    final optionC = find.text('2¹² × 3⁶ pernos.');
    await tester.ensureVisible(optionC);
    await tester.tap(optionC);
    await tester.pump();

    final verifyButton = find.text('Verificar respuesta');
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pump();

    expect(find.text('Puntaje: 1 / 60'), findsOneWidget);
    expect(find.text('Resolución paso a paso'), findsOneWidget);

    // Controller para saltos
    final studyPage = tester.widget<StudyPage>(find.byType(StudyPage));
    final controller = studyPage.controller;

    // Saltar a pregunta 6 (con imagen)
    controller.jumpToQuestion(5);
    await tester.pumpAndSettle();

    final nextP6 = find.text('Siguiente');
    await tester.ensureVisible(nextP6);
    await tester.tap(nextP6);
    await tester.pumpAndSettle();

    expect(
      find.text('Convocatoria 2025 · Competencias Matemáticas · Pregunta 6'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsWidgets);

    // Saltar a pregunta 31 (Lectura: Texto 1)
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

    // Saltar a la última pregunta (P60) y finalizar
    controller.jumpToQuestion(59);
    await tester.pumpAndSettle();

    final nextP60 = find.text('Siguiente');
    await tester.ensureVisible(nextP60);
    await tester.tap(nextP60);
    await tester.pumpAndSettle();

    final optRutinas = find.text('Establece rutinas diarias.');
    await tester.ensureVisible(optRutinas);
    await tester.tap(optRutinas);
    await tester.pump();

    final verifyP60 = find.text('Verificar respuesta');
    await tester.ensureVisible(verifyP60);
    await tester.tap(verifyP60);
    await tester.pump();

    final finishButton = find.text('Ver resultado');
    await tester.ensureVisible(finishButton);
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.text('Has completado el examen'), findsOneWidget);
    expect(find.text('2 / 60'), findsAtLeastNWidgets(1));

    // Regresar a la lista de exámenes tocando "Volver a exámenes"
    final backToExamsBtn = find.text('Volver a exámenes');
    await tester.ensureVisible(backToExamsBtn);
    await tester.tap(backToExamsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await waitForAssets(tester);

    // 4. Comprobar que en la pantalla principal ahora se muestra el progreso guardado
    expect(find.text('Completado'), findsOneWidget);
    expect(find.text('Revisar examen'), findsOneWidget);

    // 5. Cambiar de estudiante
    final changeUserBtn = find.text('Carlos');
    await tester.ensureVisible(changeUserBtn);
    await tester.tap(changeUserBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await waitForAssets(tester);

    // Ahora estamos de nuevo en el login y probamos buscar "Carlos":
    // debe detectar automáticamente el progreso previo guardado
    expect(find.text('¿Quién está estudiando hoy?'), findsOneWidget);
    final nameField2 = find.byType(TextField);
    await tester.enterText(nameField2, 'Carlos');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await waitForAssets(tester);

    expect(find.text('¡Progreso guardado encontrado!'), findsOneWidget);
    expect(find.text('Continuar donde lo dejaste'), findsOneWidget);
    expect(find.text('Reiniciar examen desde cero'), findsOneWidget);
  }

  testWidgets(
    'Flujo completo con registro por nombre, persistencia de progreso y reanudación (Desktop)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final progressRepo = InMemoryProgressRepository();
      await runTwoPhaseFlow(tester, progressRepo: progressRepo);
    },
  );

  testWidgets(
    'Flujo completo responsive en pantalla móvil (375x812) sin desbordamientos',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final progressRepo = InMemoryProgressRepository();
      await runTwoPhaseFlow(tester, progressRepo: progressRepo);
    },
  );
}
