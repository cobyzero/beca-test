import 'package:beca_test/domain/models/student_progress.dart';

/// Contrato para almacenamiento y consulta del progreso de los estudiantes.
abstract class ProgressRepository {
  /// Retorna la lista de todos los nombres de estudiantes registrados en este dispositivo.
  Future<List<String>> getSavedStudents();

  /// Retorna el último estudiante que estuvo activo en la aplicación.
  Future<String?> getLastActiveStudent();

  /// Establece cuál fue el último estudiante activo.
  Future<void> setLastActiveStudent(String studentName);

  /// Obtiene el progreso guardado de un estudiante para un año de examen específico.
  Future<ExamProgress?> getProgress({
    required String studentName,
    required int year,
  });

  /// Guarda o actualiza el progreso de un estudiante.
  Future<void> saveProgress(ExamProgress progress);

  /// Elimina el progreso guardado de un estudiante para reiniciar el examen.
  Future<void> clearProgress({
    required String studentName,
    required int year,
  });

  /// Elimina a un estudiante y todo su progreso de este dispositivo.
  Future<void> deleteStudent(String studentName);
}

