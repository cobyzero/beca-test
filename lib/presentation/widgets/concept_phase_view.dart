import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/question.dart';

/// Fase 1: Explicación del concepto y ejercicio similar con otros datos.
class ConceptPhaseView extends StatelessWidget {
  const ConceptPhaseView({
    super.key,
    required this.topic,
    required this.showExampleSolution,
    required this.onToggleExampleSolution,
    required this.onNextPhase,
  });

  final StudyTopic topic;
  final bool showExampleSolution;
  final VoidCallback onToggleExampleSolution;
  final VoidCallback onNextPhase;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final cardPadding = isMobile ? 18.0 : 28.0;
    final mechanismParagraphs = topic.mechanism
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    final analogyParagraphs = topic.analogy
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final conceptCard = Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.title,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: isMobile ? 20 : 24,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < mechanismParagraphs.length; i++) ...[
            Text(
              mechanismParagraphs[i],
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: i == 0 ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            if (i < mechanismParagraphs.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border(
                left: BorderSide(color: AppTheme.primary, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Idea visual y límite',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < analogyParagraphs.length; i++) ...[
                  Text(
                    analogyParagraphs[i],
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.foreground,
                    ),
                  ),
                  if (i < analogyParagraphs.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reglas clave',
            style: textTheme.titleMedium?.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...topic.keyPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final exampleCard = Container(
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
              horizontal: isMobile ? 18 : 24,
              vertical: 16,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.mutedSurface,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ejemplo similar (con otros datos)',
                    style: textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.workedExample.prompt,
                  style: textTheme.bodyLarge?.copyWith(fontSize: 15.5),
                ),
                if (topic.workedExample.imageAsset != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: Image.asset(
                          topic.workedExample.imageAsset!,
                          fit: BoxFit.contain,
                          semanticLabel: topic.workedExample.imageAlt,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: OutlinedButton.icon(
                    onPressed: onToggleExampleSolution,
                    icon: Icon(
                      showExampleSolution
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                    label: Text(
                      showExampleSolution
                          ? 'Ocultar procedimiento'
                          : 'Ver procedimiento y respuesta',
                    ),
                  ),
                ),
                if (showExampleSolution) ...[
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  ...topic.workedExample.steps.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _StepRow(
                        index: entry.key + 1,
                        text: entry.value.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppTheme.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Resultado del ejemplo: ${topic.workedExample.result}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 860) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: conceptCard),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: exampleCard),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                conceptCard,
                const SizedBox(height: 20),
                exampleCard,
              ],
            );
          },
        ),
        SizedBox(height: isMobile ? 20 : 28),
        if (isMobile)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNextPhase,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Siguiente'),
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onNextPhase,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Siguiente'),
            ),
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

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
