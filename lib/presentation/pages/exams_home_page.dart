import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/student_progress.dart';
import '../controllers/study_controller.dart';
import 'study_page.dart';

/// Pantalla principal con el listado de exámenes disponibles para estudiar y estado del progreso del estudiante.
class ExamsHomePage extends StatefulWidget {
  const ExamsHomePage({
    super.key,
    required this.repository,
    this.progressRepository,
    this.studentName,
    this.onChangeStudent,
  });

  final ExamRepository repository;
  final ProgressRepository? progressRepository;
  final String? studentName;
  final VoidCallback? onChangeStudent;

  @override
  State<ExamsHomePage> createState() => _ExamsHomePageState();
}

class _ExamsHomePageState extends State<ExamsHomePage> {
  late Future<Map<int, int>> _examsFuture;
  final Map<int, ExamProgress?> _studentProgressByYear = {};

  @override
  void initState() {
    super.initState();
    _examsFuture = _loadExamCounts();
    _loadProgress();
  }

  @override
  void didUpdateWidget(ExamsHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentName != widget.studentName) {
      _loadProgress();
    }
  }

  Future<Map<int, int>> _loadExamCounts() async {
    final questions = await widget.repository.loadQuestions();
    final counts = <int, int>{};
    for (final question in questions) {
      counts[question.year] = (counts[question.year] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _loadProgress() async {
    if (widget.progressRepository == null ||
        widget.studentName == null ||
        widget.studentName!.trim().isEmpty) {
      return;
    }

    final prog2025 = await widget.progressRepository!.getProgress(
      studentName: widget.studentName!,
      year: 2025,
    );

    if (mounted) {
      setState(() {
        _studentProgressByYear[2025] = prog2025;
      });
    }
  }

  void _openExam(int year, {bool startFromScratch = false}) {
    final controller = StudyController(
      repository: widget.repository,
      progressRepository: widget.progressRepository,
      studentName: widget.studentName,
      yearFilter: year,
    )..load();

    if (startFromScratch) {
      controller.resetProgress();
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StudyPage(
          controller: controller,
          onBackToExams: () {
            Navigator.of(context).pop();
            _loadProgress();
          },
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
            // Barra superior institucional
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
                      vertical: isMobile ? 12 : 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  isMobile ? 'Beca 18' : 'PRONABEC · Beca 18',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppTheme.foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.studentName != null &&
                            widget.studentName!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onChangeStudent,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.mutedSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_rounded,
                                    size: 15,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: isMobile ? 110 : 200,
                                    ),
                                    child: Text(
                                      widget.studentName!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.foreground,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 15,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                                final progress = _studentProgressByYear[year];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ExamCard(
                                    year: year,
                                    questionCount: count,
                                    isMobile: isMobile,
                                    progress: progress,
                                    onStart: () => _openExam(year),
                                    onRestart: () => _openExam(
                                      year,
                                      startFromScratch: true,
                                    ),
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
    this.progress,
    required this.onStart,
    required this.onRestart,
  });

  final int year;
  final int questionCount;
  final bool isMobile;
  final ExamProgress? progress;
  final VoidCallback onStart;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countLabel = questionCount == 1
        ? '1 pregunta disponible'
        : '$questionCount preguntas disponibles';

    final hasProgress = progress != null && progress!.answeredCount > 0;
    final isCompleted = progress != null && progress!.isCompleted;

    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
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
            if (hasProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.accentSoft
                      : AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted
                      ? 'Completado'
                      : 'Pregunta ${progress!.currentIndex + 1} de $questionCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppTheme.accent
                        : AppTheme.foreground,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Simulacro Beca 18 · $year',
          style: textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          hasProgress
              ? '${progress!.answeredCount} de $questionCount respondidas · 1 punto por pregunta'
              : '$countLabel · 1 punto por pregunta',
          style: textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
        if (hasProgress) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress!.answeredCount / questionCount,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ),
        ],
      ],
    );

    final actionButtons = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: isMobile ? WrapAlignment.start : WrapAlignment.end,
      children: [
        if (hasProgress)
          OutlinedButton.icon(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Reiniciar examen?'),
                  content: const Text(
                    'Se borrarán las respuestas guardadas de este examen y comenzarás nuevamente desde la Pregunta 1.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.destructive,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRestart();
                      },
                      child: const Text('Sí, reiniciar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reiniciar'),
          ),
        FilledButton.icon(
          onPressed: onStart,
          icon: Icon(
            hasProgress ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
            size: 18,
          ),
          label: Text(
            hasProgress
                ? (isCompleted ? 'Revisar examen' : 'Continuar estudio')
                : 'Comenzar estudio',
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoColumn,
                const SizedBox(height: 16),
                actionButtons,
              ],
            )
          : Row(
              children: [
                Expanded(child: infoColumn),
                const SizedBox(width: 24),
                actionButtons,
              ],
            ),
    );
  }
}
