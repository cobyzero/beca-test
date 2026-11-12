import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/exam_repository.dart';
import 'presentation/pages/exams_home_page.dart';

void main() {
  runApp(const BecaStudyApp());
}

/// Aplicación web de estudio para exámenes Beca 18 (PRONABEC).
class BecaStudyApp extends StatelessWidget {
  const BecaStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRONABEC · Beca 18 Study',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ExamsHomePage(
        repository: AssetExamRepository(),
      ),
    );
  }
}
