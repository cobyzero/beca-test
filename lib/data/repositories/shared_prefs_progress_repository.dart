import 'dart:convert';
import 'package:beca_test/data/repositories/progress_repository.dart';
import 'package:beca_test/domain/models/student_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementación de persistencia local usando SharedPreferences
/// (WebStorage / IndexedDB en Flutter Web).
class SharedPrefsProgressRepository implements ProgressRepository {
  static const _studentsListKey = 'beca18_saved_students_v1';
  static const _lastActiveStudentKey = 'beca18_last_active_student_v1';

  String _progressKey(String studentName, int year) {
    final cleanName = studentName.trim().toLowerCase();
    return 'beca18_progress_${cleanName}_$year';
  }

  @override
  Future<List<String>> getSavedStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_studentsListKey) ?? [];
    return list;
  }

  @override
  Future<String?> getLastActiveStudent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastActiveStudentKey);
  }

  @override
  Future<void> setLastActiveStudent(String studentName) async {
    final cleanName = studentName.trim();
    if (cleanName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActiveStudentKey, cleanName);

    // Asegurarse de que esté en la lista general de estudiantes
    final currentList = prefs.getStringList(_studentsListKey) ?? [];
    if (!currentList.contains(cleanName)) {
      currentList.insert(0, cleanName);
      await prefs.setStringList(_studentsListKey, currentList);
    }
  }

  @override
  Future<ExamProgress?> getProgress({
    required String studentName,
    required int year,
  }) async {
    final cleanName = studentName.trim();
    if (cleanName.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey(cleanName, year));
    if (raw == null || raw.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      return ExamProgress.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProgress(ExamProgress progress) async {
    final cleanName = progress.studentName.trim();
    if (cleanName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _progressKey(cleanName, progress.year);
    progress.updatedAt = DateTime.now();
    await prefs.setString(key, progress.serialize());

    // Asegurar que el estudiante figure en la lista y como último activo
    await setLastActiveStudent(cleanName);
  }

  @override
  Future<void> clearProgress({
    required String studentName,
    required int year,
  }) async {
    final cleanName = studentName.trim();
    if (cleanName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey(cleanName, year));
  }

  @override
  Future<void> deleteStudent(String studentName) async {
    final cleanName = studentName.trim();
    if (cleanName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final currentList = prefs.getStringList(_studentsListKey) ?? [];
    currentList.remove(cleanName);
    await prefs.setStringList(_studentsListKey, currentList);

    if (prefs.getString(_lastActiveStudentKey) == cleanName) {
      await prefs.remove(_lastActiveStudentKey);
    }

    // Remover progresos de años comunes (ej. 2024, 2025)
    await prefs.remove(_progressKey(cleanName, 2024));
    await prefs.remove(_progressKey(cleanName, 2025));
  }
}

