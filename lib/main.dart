import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/exam_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/shared_prefs_progress_repository.dart';
import 'presentation/pages/exams_home_page.dart';
import 'presentation/pages/student_login_page.dart';

void main() {
  runApp(const BecaStudyApp());
}

/// Aplicación web de estudio para exámenes Beca 18 (PRONABEC).
class BecaStudyApp extends StatefulWidget {
  const BecaStudyApp({
    super.key,
    this.examRepository = const AssetExamRepository(),
    this.progressRepository,
    this.initialStudentName,
  });

  final ExamRepository examRepository;
  final ProgressRepository? progressRepository;
  final String? initialStudentName;

  @override
  State<BecaStudyApp> createState() => _BecaStudyAppState();
}

class _BecaStudyAppState extends State<BecaStudyApp> {
  late final ProgressRepository _progressRepository;
  String? _currentStudent;

  @override
  void initState() {
    super.initState();
    _progressRepository =
        widget.progressRepository ?? SharedPrefsProgressRepository();
    _currentStudent = widget.initialStudentName;
  }

  void _onStudentSelected(String studentName, bool startFromScratch) {
    setState(() {
      _currentStudent = studentName.trim();
    });
  }

  void _onChangeStudent() {
    setState(() {
      _currentStudent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRONABEC · Beca 18 Study',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _currentStudent == null
          ? StudentLoginPage(
              progressRepository: _progressRepository,
              onContinue: _onStudentSelected,
            )
          : ExamsHomePage(
              repository: widget.examRepository,
              progressRepository: _progressRepository,
              studentName: _currentStudent,
              onChangeStudent: _onChangeStudent,
            ),
    );
  }
}
