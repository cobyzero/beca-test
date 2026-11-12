import 'package:beca_test/data/repositories/progress_repository.dart';
import 'package:beca_test/domain/models/student_progress.dart';

/// Implementación en memoria para tests y entornos sin almacenamiento persistente.
class InMemoryProgressRepository implements ProgressRepository {
  final List<String> _students = [];
  String? _lastActive;
  final Map<String, ExamProgress> _storage = {};

  String _key(String name, int year) => '${name.trim().toLowerCase()}_$year';

  @override
  Future<List<String>> getSavedStudents() async => List.unmodifiable(_students);

  @override
  Future<String?> getLastActiveStudent() async => _lastActive;

  @override
  Future<void> setLastActiveStudent(String studentName) async {
    final clean = studentName.trim();
    if (clean.isEmpty) return;
    _lastActive = clean;
    if (!_students.contains(clean)) {
      _students.insert(0, clean);
    }
  }

  @override
  Future<ExamProgress?> getProgress({
    required String studentName,
    required int year,
  }) async {
    return _storage[_key(studentName, year)];
  }

  @override
  Future<void> saveProgress(ExamProgress progress) async {
    final clean = progress.studentName.trim();
    if (clean.isEmpty) return;
    _storage[_key(clean, progress.year)] = progress;
    await setLastActiveStudent(clean);
  }

  @override
  Future<void> clearProgress({
    required String studentName,
    required int year,
  }) async {
    _storage.remove(_key(studentName, year));
  }

  @override
  Future<void> deleteStudent(String studentName) async {
    final clean = studentName.trim();
    _students.remove(clean);
    if (_lastActive == clean) _lastActive = null;
    _storage.remove(_key(clean, 2024));
    _storage.remove(_key(clean, 2025));
  }
}

