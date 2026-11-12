# Memoria y Contexto del Proyecto — PRONABEC Beca 18 Study App

Este archivo guarda el contexto permanente del proyecto para asistentes de IA.

## 1. Objetivo del proyecto
Aplicación **Flutter Web** diseñada para ayudar a estudiantes a prepararse para el examen de selección de **Beca 18 (PRONABEC)**.
- Cada pregunta proviene de exámenes oficiales/simulacros pasados.
- **Regla fundamental:** cada pregunta debe incluir un **tema de estudio** asociado (`StudyTopic`) con explicación teórica, fórmulas o reglas clave y resolución paso a paso para que el estudiante entienda el porqué de la respuesta.

## 2. Fuente de datos (PDFs de exámenes)
Los PDFs originales se encuentran en:
`/Users/SebastianAbal/Desktop/beca/`
- `examen-2-beca-18-convocatoria-2024.pdf` (28 páginas)
- `examen-3-beca-18-convocatoria-2025.pdf` (28 páginas)

### Estructura observada (Convocatoria 2025)
- **Preguntas 1 – 30:** Competencias Matemáticas
- **Preguntas 31 – 60:** Competencia Lectora
- **Página 28:** Tabla oficial de claves (`CLAVES PARA EL SIMULACRO BECA 18 - CONVOCATORIA 2025`).

### Nota técnica importante al leer los PDFs
El texto extraído directamente con `pypdf` tiene codificación desplazada/personalizada en varios bloques (por ejemplo, exponentes y símbolos matemáticos no se extraen correctamente). **Siempre renderizar las páginas a PNG con `pymupdf` (`fitz`)** y revisar visualmente las imágenes antes de transcribir preguntas, opciones o claves.

## 3. Arquitectura (Limpia y Simple)
El proyecto usa Flutter 3.47.7 (gestionado con `fvm`) orientado a **Web**, con una separación simple en 3 capas dentro de `lib/`:
- `lib/core/` — Tema visual (`app_theme.dart`) y utilidades compartidas.
- `lib/domain/` — Modelos puros (`Question`, `AnswerOption`, `StudyTopic`, `ExamArea`).
- `lib/data/` — Repositorios (`ExamRepository`, `AssetExamRepository`) que cargan el banco de preguntas y clases desde `assets/data/questions.json`.
- `assets/data/questions.json` — Banco de preguntas y clases (`StudyTopic` con ejemplo similar) cargado al inicio de la app.
- `lib/presentation/` — Estado (`StudyController` con `ChangeNotifier`), páginas (`StudyPage`) y widgets (`QuestionCard`, `StudyTopicCard`).

### Convenciones
- Mantener la arquitectura simple: sin dependencias externas innecesarias ni sobreingeniería.
- Usar `fvm flutter` para comandos de Flutter (`fvm flutter analyze`, `fvm flutter test`, `fvm flutter run -d chrome`, `fvm flutter build web`).
- Todo el texto de la interfaz y contenido educativo debe estar en **español**.
- Al agregar nuevas preguntas:
  1. Verificar enunciado, opciones (`a`, `b`, `c`, `d`) y clave oficial desde la imagen renderizada del PDF.
  2. Redactar su `StudyTopic` correspondiente aplicando la skill instalada en `.agents/skills/feynman-technique/SKILL.md` (mecanismo primero y nombre técnico después, analogía clara con límites honestos, sin jerga sin definir y solución paso a paso).

## 4. Estado actual
- **Convocatoria 2025:** ¡Completada al 100%! Las **60 preguntas** (1–30 Competencias Matemáticas y 31–60 Competencia Lectora) están transcritas, verificadas contra la clave oficial de la pág. 28, vinculadas a sus imágenes/infografías correspondientes en `assets/images/2025/` y con su `StudyTopic` (técnica Feynman con procedimiento ocultable) en `assets/data/questions.json`.
- **Convocatoria 2024:** Pendiente de incorporar preguntas (`examen-2-beca-18-convocatoria-2024.pdf`).

