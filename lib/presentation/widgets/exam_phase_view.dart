import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/question.dart';

/// Fase 2: Pregunta oficial del examen, verificación y resolución paso a paso.
class ExamPhaseView extends StatelessWidget {
  const ExamPhaseView({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.isVerified,
    required this.isLastQuestion,
    required this.onSelectOption,
    required this.onVerify,
    required this.onBackToConcept,
    required this.onFinishExam,
    this.onNextQuestion,
  });

  final Question question;
  final String? selectedOptionId;
  final bool isVerified;
  final bool isLastQuestion;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onVerify;
  final VoidCallback onBackToConcept;
  final VoidCallback onFinishExam;
  final VoidCallback? onNextQuestion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final cardPadding = isMobile ? 18.0 : 28.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadding,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.mutedSurface,
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: Text(
                  'Convocatoria ${question.year} · ${question.area.label} · Pregunta ${question.number}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (question.readingPassage != null) ...[
                      _ReadingPassageBox(passage: question.readingPassage!),
                      const SizedBox(height: 20),
                    ],
                    Text(question.prompt, style: textTheme.bodyLarge),
                    if (question.imageAsset != null) ...[
                      const SizedBox(height: 18),
                      _QuestionImageBox(
                        assetPath: question.imageAsset!,
                        semanticLabel: question.imageAlt,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ...question.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OptionRow(
                          option: option,
                          isSelected: selectedOptionId == option.id,
                          isVerified: isVerified,
                          isCorrectOption:
                              option.id == question.correctOptionId,
                          onTap: () => onSelectOption(option.id),
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(height: 14),
                      _ResultNotice(
                        isCorrect: question.isCorrect(selectedOptionId),
                        correctOptionId: question.correctOptionId,
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Text(
                        'Resolución paso a paso',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      ...question.studyTopic.examSolutionSteps
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ExamStepRow(
                                index: entry.key + 1,
                                text: entry.value.replaceFirst(
                                  RegExp(r'^\d+\.\s*'),
                                  '',
                                ),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isVerified) ...[
                FilledButton(
                  onPressed: selectedOptionId == null ? null : onVerify,
                  child: const Text('Verificar respuesta'),
                ),
                const SizedBox(height: 10),
              ] else if (isLastQuestion) ...[
                FilledButton.icon(
                  onPressed: onFinishExam,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Ver resultado'),
                ),
                const SizedBox(height: 10),
              ] else if (onNextQuestion != null) ...[
                FilledButton.icon(
                  onPressed: onNextQuestion,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Siguiente pregunta'),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: onBackToConcept,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Volver al concepto'),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: onBackToConcept,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Volver al concepto'),
              ),
              if (!isVerified)
                FilledButton(
                  onPressed: selectedOptionId == null ? null : onVerify,
                  child: const Text('Verificar respuesta'),
                )
              else if (isLastQuestion)
                FilledButton.icon(
                  onPressed: onFinishExam,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Ver resultado'),
                )
              else if (onNextQuestion != null)
                FilledButton.icon(
                  onPressed: onNextQuestion,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Siguiente pregunta'),
                ),
            ],
          ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.isSelected,
    required this.isVerified,
    required this.isCorrectOption,
    required this.onTap,
  });

  final AnswerOption option;
  final bool isSelected;
  final bool isVerified;
  final bool isCorrectOption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppTheme.border;
    Color backgroundColor = AppTheme.surface;
    Color badgeBg = AppTheme.mutedSurface;
    Color badgeFg = AppTheme.mutedForeground;
    IconData? statusIcon;
    Color? statusColor;

    if (isVerified) {
      if (isCorrectOption) {
        borderColor = AppTheme.accent;
        backgroundColor = AppTheme.accentSoft;
        badgeBg = AppTheme.accent;
        badgeFg = Colors.white;
        statusIcon = Icons.check_circle_rounded;
        statusColor = AppTheme.accent;
      } else if (isSelected) {
        borderColor = AppTheme.destructive;
        backgroundColor = AppTheme.destructiveSoft;
        badgeBg = AppTheme.destructive;
        badgeFg = Colors.white;
        statusIcon = Icons.cancel_rounded;
        statusColor = AppTheme.destructive;
      }
    } else if (isSelected) {
      borderColor = AppTheme.primary;
      backgroundColor = AppTheme.primarySoft;
      badgeBg = AppTheme.primary;
      badgeFg = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isVerified ? null : onTap,
        hoverColor: AppTheme.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: (isSelected || (isVerified && isCorrectOption)) ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  option.id,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (option.text.isNotEmpty)
                      Text(
                        option.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.foreground,
                        ),
                      ),
                    if (option.imageAsset != null) ...[
                      if (option.text.isNotEmpty) const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 90),
                        child: Image.asset(
                          option.imageAsset!,
                          fit: BoxFit.contain,
                          semanticLabel: option.imageAlt,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (statusIcon != null) ...[
                const SizedBox(width: 12),
                Icon(statusIcon, color: statusColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultNotice extends StatelessWidget {
  const _ResultNotice({
    required this.isCorrect,
    required this.correctOptionId,
  });

  final bool isCorrect;
  final String correctOptionId;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.accent : AppTheme.destructive;
    final bgColor = isCorrect ? AppTheme.accentSoft : AppTheme.destructiveSoft;
    final icon = isCorrect ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded;
    final text = isCorrect
        ? 'Correcto. Revisa la resolución para confirmar el procedimiento.'
        : 'Incorrecto. La alternativa correcta es la "$correctOptionId".';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamStepRow extends StatelessWidget {
  const _ExamStepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.mutedSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.foreground,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.foreground,
                ),
          ),
        ),
      ],
    );
  }
}

class _ReadingPassageBox extends StatelessWidget {
  const _ReadingPassageBox({required this.passage});

  final String passage;

  @override
  Widget build(BuildContext context) {
    final paragraphs = passage
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.mutedSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lectura',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < paragraphs.length; i++) ...[
            Text(
              paragraphs[i],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.foreground,
                    height: 1.65,
                  ),
            ),
            if (i < paragraphs.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _QuestionImageBox extends StatelessWidget {
  const _QuestionImageBox({
    required this.assetPath,
    this.semanticLabel,
  });

  final String assetPath;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
