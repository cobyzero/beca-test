import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/exam_repository.dart';
import '../controllers/study_controller.dart';
import 'study_page.dart';

/// Pantalla principal con el listado de exámenes disponibles para estudiar.
class ExamsHomePage extends StatefulWidget {
  const ExamsHomePage({super.key, required this.repository});

  final ExamRepository repository;

  @override
  State<ExamsHomePage> createState() => _ExamsHomePageState();
}

class _ExamsHomePageState extends State<ExamsHomePage> {
  late Future<Map<int, int>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _examsFuture = _loadExamCounts();
  }

  Future<Map<int, int>> _loadExamCounts() async {
    final questions = await widget.repository.loadQuestions();
    final counts = <int, int>{};
    for (final question in questions) {
      counts[question.year] = (counts[question.year] ?? 0) + 1;
    }
    return counts;
  }

  void _openExam(int year) {
    final controller = StudyController(
      repository: widget.repository,
      yearFilter: year,
    )..load();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StudyPage(
          controller: controller,
          onBackToExams: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
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
                      vertical: isMobile ? 14 : 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'PRONABEC · Beca 18',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 24 : 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exámenes de preparación',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: isMobile ? 22 : 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cada pregunta incluye una explicación previa con ejemplo similar antes de pasar al examen.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),
                        FutureBuilder<Map<int, int>>(
                          future: _examsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No se pudieron cargar los exámenes.',
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _examsFuture = _loadExamCounts();
                                        });
                                      },
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final exams = snapshot.data ?? const {};
                            final years = exams.keys.toList()
                              ..sort((a, b) => b.compareTo(a));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: years.map((year) {
                                final count = exams[year] ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ExamCard(
                                    year: year,
                                    questionCount: count,
                                    isMobile: isMobile,
                                    onStart: () => _openExam(year),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
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
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.year,
    required this.questionCount,
    required this.isMobile,
    required this.onStart,
  });

  final int year;
  final int questionCount;
  final bool isMobile;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countLabel = questionCount == 1
        ? '1 pregunta disponible'
        : '$questionCount preguntas disponibles';

    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primarySoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Convocatoria $year',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Simulacro Beca 18 · $year',
          style: textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          '$countLabel · 1 punto por pregunta',
          style: textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoColumn,
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Comenzar estudio'),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: infoColumn),
                const SizedBox(width: 24),
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Comenzar estudio'),
                ),
              ],
            ),
    );
  }
}

