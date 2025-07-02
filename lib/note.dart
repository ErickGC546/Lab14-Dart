class NoteFields {
  static const String tableName = 'notes';

  static const String id = '_id';
  static const String titulo = 'titulo';
  static const String calificacion = 'calificacion';
  static const String esImportante = 'esImportante';
  static const String fechaCreacion = 'fechaCreacion';

  static const List<String> values = [
    id,
    titulo,
    calificacion,
    esImportante,
    fechaCreacion,
  ];
}

class NoteModel {
  final int? id;
  final String titulo;
  final double calificacion;
  final bool esImportante;
  final DateTime fechaCreacion;

  NoteModel({
    this.id,
    required this.titulo,
    required this.calificacion,
    required this.esImportante,
    required this.fechaCreacion,
  });

  Map<String, Object?> toJson() => {
    NoteFields.id: id,
    NoteFields.titulo: titulo,
    NoteFields.calificacion: calificacion,
    NoteFields.esImportante: esImportante ? 1 : 0,
    NoteFields.fechaCreacion: fechaCreacion.toIso8601String(),
  };

  factory NoteModel.fromJson(Map<String, Object?> json) => NoteModel(
    id: json[NoteFields.id] as int?,
    titulo: json[NoteFields.titulo] as String,
    calificacion: json[NoteFields.calificacion] as double,
    esImportante: json[NoteFields.esImportante] == 1,
    fechaCreacion: DateTime.parse(json[NoteFields.fechaCreacion] as String),
  );

  NoteModel copy({
    int? id,
    String? titulo,
    double? calificacion,
    bool? esImportante,
    DateTime? fechaCreacion,
  }) => NoteModel(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    calificacion: calificacion ?? this.calificacion,
    esImportante: esImportante ?? this.esImportante,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
  );
}
