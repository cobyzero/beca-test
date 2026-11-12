import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/student_progress.dart';

/// Pantalla de acceso mejorada con identidad institucional de Beca 18,
/// avatar interactivo, búsqueda de progreso en tiempo real y selector de perfiles.
class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({
    super.key,
    required this.progressRepository,
    required this.onContinue,
  });

  final ProgressRepository progressRepository;
  final void Function(String studentName, bool startFromScratch) onContinue;

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _nameController = TextEditingController();
  List<String> _savedStudents = [];
  final Map<String, ExamProgress?> _studentProgressMap = {};
  ExamProgress? _foundProgress;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final list = await widget.progressRepository.getSavedStudents();
    final lastActive = await widget.progressRepository.getLastActiveStudent();

    // Precargar progreso de cada estudiante guardado para mostrar en sus tarjetas
    for (final name in list) {
      final p2025 = await widget.progressRepository.getProgress(
        studentName: name,
        year: 2025,
      );
      final p2024 = await widget.progressRepository.getProgress(
        studentName: name,
        year: 2024,
      );
      final prog = (p2025 != null && p2024 != null)
          ? (p2025.updatedAt.isAfter(p2024.updatedAt) ? p2025 : p2024)
          : (p2025 ?? p2024);
      _studentProgressMap[name] = prog;
    }

    if (mounted) {
      setState(() {
        _savedStudents = list;
      });

      if (lastActive != null && lastActive.isNotEmpty) {
        _nameController.text = lastActive;
      }
    }
  }

  Future<void> _onNameChanged() async {
    final query = _nameController.text.trim();
    if (query.isEmpty) {
      if (_foundProgress != null) {
        setState(() {
          _foundProgress = null;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final p2025 = await widget.progressRepository.getProgress(
      studentName: query,
      year: 2025,
    );
    final p2024 = await widget.progressRepository.getProgress(
      studentName: query,
      year: 2024,
    );
    final progress = (p2025 != null && p2024 != null)
        ? (p2025.updatedAt.isAfter(p2024.updatedAt) ? p2025 : p2024)
        : (p2025 ?? p2024);

    if (mounted && _nameController.text.trim() == query) {
      setState(() {
        _foundProgress = progress;
        _isSearching = false;
      });
    }
  }

  void _submit({bool startFromScratch = false}) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onContinue(name, startFromScratch);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final cleanName = _nameController.text.trim();
    final initials = cleanName.isNotEmpty ? _getInitials(cleanName) : '👤';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Cinta institucional superior (bandera peruana y sello)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(color: AppTheme.primary, width: 3.5),
                  bottom: BorderSide(color: AppTheme.border),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 28,
                vertical: 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                isMobile ? 'PRONABEC · Beca 18' : 'PRONABEC · Plataforma de Preparación Beca 18',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.foreground,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contenido central desplazable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 32,
                  vertical: isMobile ? 24 : 36,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabecera Hero con título motivacional
                        Text(
                          '¿Quién está estudiando hoy?',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ingresa tu nombre o alias para guardar tu progreso automáticamente. Sin contraseñas ni registros complicados.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14.5,
                            height: 1.5,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Píldoras de beneficios clave
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FeatureBadge(
                                icon: Icons.calculate_outlined,
                                label: '30 Matemáticas',
                              ),
                              const SizedBox(width: 8),
                              _FeatureBadge(
                                icon: Icons.auto_stories_outlined,
                                label: '30 Lectura',
                              ),
                              const SizedBox(width: 8),
                              _FeatureBadge(
                                icon: Icons.lightbulb_outline_rounded,
                                label: 'Técnica Feynman',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tarjeta Principal de Identificación
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Franja decorativa roja superior en la tarjeta
                              Container(
                                height: 4,
                                width: double.infinity,
                                color: AppTheme.primary,
                              ),
                              Padding(
                                padding: EdgeInsets.all(isMobile ? 20 : 28),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Fila de Avatar dinámico e Input
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Avatar con iniciales reactivo
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: cleanName.isNotEmpty
                                              ? AppTheme.primary
                                              : AppTheme.mutedSurface,
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              fontSize: cleanName.isNotEmpty
                                                  ? 17
                                                  : 20,
                                              fontWeight: FontWeight.w700,
                                              color: cleanName.isNotEmpty
                                                  ? Colors.white
                                                  : AppTheme.mutedForeground,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Tu nombre o alias',
                                                style: textTheme.titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Ejemplo: Carlos Quispe o Ana M.',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      fontSize: 12.5,
                                                      color: AppTheme
                                                          .mutedForeground,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Campo de Texto Principal
                                    TextField(
                                      controller: _nameController,
                                      autofocus: false,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.foreground,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Escribe tu nombre aquí...',
                                        hintStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: AppTheme.mutedForeground,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.edit_note_rounded,
                                          color: AppTheme.primary,
                                          size: 22,
                                        ),
                                        suffixIcon: cleanName.isNotEmpty
                                            ? IconButton(
                                                tooltip: 'Limpiar nombre',
                                                icon: const Icon(
                                                  Icons.cancel_rounded,
                                                  size: 18,
                                                ),
                                                onPressed: () =>
                                                    _nameController.clear(),
                                              )
                                            : null,
                                        filled: true,
                                        fillColor: AppTheme.mutedSurface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppTheme.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppTheme.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppTheme.primary,
                                            width: 1.8,
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (_) => _submit(),
                                    ),
                                    const SizedBox(height: 20),

                                    // Estado Dinámico de Búsqueda
                                    if (cleanName.isNotEmpty) ...[
                                      if (_isSearching)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        )
                                      else if (_foundProgress != null) ...[
                                        // Tarjeta de progreso encontrado
                                        _ProgressFoundCard(
                                          progress: _foundProgress!,
                                          studentName: cleanName,
                                        ),
                                        const SizedBox(height: 18),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              48,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _submit(startFromScratch: false),
                                          icon: const Icon(
                                            Icons.play_arrow_rounded,
                                            size: 22,
                                          ),
                                          label: const Text(
                                            'Continuar donde lo dejaste',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              44,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _submit(startFromScratch: true),
                                          icon: const Icon(
                                            Icons.restart_alt_rounded,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Reiniciar examen desde cero',
                                          ),
                                        ),
                                      ] else ...[
                                        // Nuevo estudiante detectado
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primarySoft,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppTheme.primary
                                                  .withValues(alpha: 0.18),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.stars_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Nuevo registro. Comenzarás desde la Pregunta 1.',
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppTheme.foreground,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Aprenderás primero la teoría con la técnica Feynman antes de responder.',
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        color: AppTheme
                                                            .mutedForeground,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              48,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => _submit(),
                                          icon: const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                          ),
                                          label: const Text(
                                            'Comenzar estudio',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ] else ...[
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            48,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: null,
                                        child: const Text(
                                          'Ingresa tu nombre para continuar',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sección de perfiles guardados anteriormente
                        if (_savedStudents.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: AppTheme.mutedForeground,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Estudiantes guardados en este dispositivo',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: _savedStudents.map((name) {
                              final isSelected =
                                  cleanName.toLowerCase() ==
                                  name.trim().toLowerCase();
                              final prog = _studentProgressMap[name];
                              final hasProg =
                                  prog != null && prog.answeredCount > 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    _nameController.text = name;
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primarySoft
                                          : AppTheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : AppTheme.border,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 17,
                                          backgroundColor: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.mutedSurface,
                                          child: Text(
                                            _getInitials(name),
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppTheme.primary
                                                      : AppTheme.foreground,
                                                ),
                                              ),
                                              Text(
                                                hasProg
                                                    ? 'Pregunta ${prog.currentIndex + 1} de 60 · ${prog.answeredCount} respondidas'
                                                    : 'Sin progreso iniciado',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.mutedForeground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.mutedForeground,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Pie institucional de garantía y privacidad
                        const SizedBox(height: 36),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: AppTheme.accent,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tus datos y avance se guardan de forma 100% privada en tu navegador. Puedes retomar tu estudio cuando desees.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.mutedForeground,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressFoundCard extends StatelessWidget {
  const _ProgressFoundCard({required this.progress, required this.studentName});

  final ExamProgress progress;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final answeredRatio = progress.answeredCount / 60;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Progreso guardado encontrado!',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    Text(
                      'Hola de nuevo, $studentName',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricBox(
                label: 'Pregunta',
                value: '${progress.currentIndex + 1} / 60',
              ),
              const SizedBox(width: 8),
              _MetricBox(
                label: 'Respondidas',
                value: '${progress.answeredCount}',
              ),
              const SizedBox(width: 8),
              _MetricBox(label: 'Puntaje', value: '${progress.score} pts'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: answeredRatio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
