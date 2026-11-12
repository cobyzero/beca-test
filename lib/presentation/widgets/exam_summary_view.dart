import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Vista final del examen que muestra el puntaje obtenido y permite revisar el examen.
class ExamSummaryView extends StatelessWidget {
  const ExamSummaryView({
    super.key,
    required this.year,
    required this.score,
    required this.totalQuestions,
    required this.onReviewExam,
    required this.onBackToExams,
  });

  final int year;
  final int score;
  final int totalQuestions;
  final VoidCallback onReviewExam;
  final VoidCallback onBackToExams;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final padding = isMobile ? 20.0 : 32.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Convocatoria $year · Resultado final',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Has completado el examen',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: isMobile ? 21 : 24,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.mutedSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'Puntaje obtenido',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      totalQuestions == 1
                          ? '1 punto por pregunta correcta'
                          : 'Cada pregunta correcta vale 1 punto',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (isMobile) ...[
                FilledButton.icon(
                  onPressed: onReviewExam,
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text('Ver examen'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onBackToExams,
                  child: const Text('Volver a exámenes'),
                ),
              ] else
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: onBackToExams,
                      child: const Text('Volver a exámenes'),
                    ),
                    FilledButton.icon(
                      onPressed: onReviewExam,
                      icon: const Icon(Icons.assignment_outlined, size: 18),
                      label: const Text('Ver examen'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
