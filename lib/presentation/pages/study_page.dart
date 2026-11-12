import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/question.dart';
import '../controllers/study_controller.dart';
import '../widgets/concept_phase_view.dart';
import '../widgets/exam_phase_view.dart';
import '../widgets/exam_summary_view.dart';

/// Página principal con diseño web minimalista y adaptable a móvil.
class StudyPage extends StatelessWidget {
  const StudyPage({
    super.key,
    required this.controller,
    required this.onBackToExams,
  });

  final StudyController controller;
  final VoidCallback onBackToExams;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: controller.load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!controller.hasQuestions) {
          return const Scaffold(
            body: Center(
              child: Text('No hay preguntas disponibles por el momento.'),
            ),
          );
        }

        final question = controller.currentQuestion;
        final isConcept = controller.currentPhase == StudyPhase.concept;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _WebHeader(
                  currentIndex: controller.currentIndex,
                  totalQuestions: controller.totalQuestions,
                  score: controller.score,
                  currentPhase: controller.currentPhase,
                  isMobile: isMobile,
                  onBackToExams: onBackToExams,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: isMobile ? 20 : 36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (controller.isExamFinished)
                              ExamSummaryView(
                                year: question.year,
                                score: controller.score,
                                totalQuestions: controller.totalQuestions,
                                onReviewExam: controller.reviewExam,
                                onBackToExams: onBackToExams,
                              )
                            else ...[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: isConcept
                                    ? ConceptPhaseView(
                                        key: ValueKey('${question.id}-concept'),
                                        topic: question.studyTopic,
                                        showExampleSolution: controller
                                            .showWorkedExampleSolution,
                                        onToggleExampleSolution: controller
                                            .toggleWorkedExampleSolution,
                                        onNextPhase: controller.goToExamPhase,
                                      )
                                    : Center(
                                        key: ValueKey('${question.id}-exam'),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 720,
                                          ),
                                          child: ExamPhaseView(
                                            question: question,
                                            selectedOptionId:
                                                controller.selectedOptionId,
                                            isVerified: controller.isVerified,
                                            isLastQuestion:
                                                controller.isLastQuestion,
                                            onSelectOption:
                                                controller.selectOption,
                                            onVerify: controller.verifyAnswer,
                                            onBackToConcept:
                                                controller.goToConceptPhase,
                                            onFinishExam: controller.finishExam,
                                            onNextQuestion: controller.canGoNext
                                                ? controller.nextQuestion
                                                : null,
                                          ),
                                        ),
                                      ),
                              ),
                              if (controller.totalQuestions > 1) ...[
                                SizedBox(height: isMobile ? 24 : 36),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (isMobile)
                                      IconButton.filledTonal(
                                        tooltip: 'Pregunta anterior',
                                        onPressed: controller.canGoPrevious
                                            ? controller.previousQuestion
                                            : null,
                                        icon: const Icon(Icons.arrow_back_rounded),
                                      )
                                    else
                                      TextButton.icon(
                                        onPressed: controller.canGoPrevious
                                            ? controller.previousQuestion
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                        label: const Text('Pregunta anterior'),
                                      ),
                                    DropdownButton<int>(
                                      value: controller.currentIndex,
                                      underline: const SizedBox.shrink(),
                                      borderRadius: BorderRadius.circular(10),
                                      items: List.generate(
                                        controller.totalQuestions,
                                        (index) => DropdownMenuItem<int>(
                                          value: index,
                                          child: Text(
                                            isMobile
                                                ? 'P${index + 1} de ${controller.totalQuestions}'
                                                : 'Pregunta ${index + 1} de ${controller.totalQuestions}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onChanged: (index) {
                                        if (index != null) {
                                          controller.jumpToQuestion(index);
                                        }
                                      },
                                    ),
                                    if (isMobile)
                                      IconButton.filledTonal(
                                        tooltip: 'Pregunta siguiente',
                                        onPressed: controller.canGoNext
                                            ? controller.nextQuestion
                                            : null,
                                        icon: const Icon(Icons.arrow_forward_rounded),
                                      )
                                    else
                                      TextButton.icon(
                                        onPressed: controller.canGoNext
                                            ? controller.nextQuestion
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                        label: const Text('Pregunta siguiente'),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WebHeader extends StatelessWidget {
  const _WebHeader({
    required this.currentIndex,
    required this.totalQuestions,
    required this.score,
    required this.currentPhase,
    required this.isMobile,
    required this.onBackToExams,
  });

  final int currentIndex;
  final int totalQuestions;
  final int score;
  final StudyPhase currentPhase;
  final bool isMobile;
  final VoidCallback onBackToExams;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.primary, width: 3),
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 12 : 14,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: _BrandTitle(onBack: onBackToExams)),
                          const SizedBox(width: 8),
                          _ScoreBadge(
                            score: score,
                            totalQuestions: totalQuestions,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: _ReadOnlyPhaseIndicator(
                                currentPhase: currentPhase,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currentIndex + 1} / $totalQuestions',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: _BrandTitle(onBack: onBackToExams)),
                            const SizedBox(width: 12),
                            Text(
                              'Pregunta ${currentIndex + 1} de $totalQuestions',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ScoreBadge(
                            score: score,
                            totalQuestions: totalQuestions,
                          ),
                          const SizedBox(width: 16),
                          _ReadOnlyPhaseIndicator(currentPhase: currentPhase),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.totalQuestions});

  final int score;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.mutedSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        'Puntaje: $score / $totalQuestions',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.foreground,
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onBack,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: AppTheme.mutedForeground,
            ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Beca 18 · Estudio',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador visual de progreso (solo lectura; el avance es únicamente con "Siguiente").
class _ReadOnlyPhaseIndicator extends StatelessWidget {
  const _ReadOnlyPhaseIndicator({required this.currentPhase});

  final StudyPhase currentPhase;

  @override
  Widget build(BuildContext context) {
    final isConcept = currentPhase == StudyPhase.concept;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBadge(
          step: '1',
          label: 'Concepto',
          isActive: isConcept,
          isDone: !isConcept,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 20,
            child: Divider(color: AppTheme.border, thickness: 1.5),
          ),
        ),
        _StepBadge(
          step: '2',
          label: 'Examen',
          isActive: !isConcept,
          isDone: false,
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  final String step;
  final String label;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isDone
        ? AppTheme.accent
        : isActive
            ? AppTheme.primary
            : AppTheme.border;
    final Color textColor =
        isActive || isDone ? AppTheme.foreground : AppTheme.mutedForeground;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive || isDone ? circleColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 13, color: Colors.white)
              : Text(
                  step,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppTheme.mutedForeground,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
