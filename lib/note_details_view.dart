import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'note.dart';
import 'note_database.dart';

class NoteDetailsView extends StatefulWidget {
  final int? noteId;

  const NoteDetailsView({super.key, this.noteId});

  @override
  State<NoteDetailsView> createState() => _NoteDetailsViewState();
}

class _NoteDetailsViewState extends State<NoteDetailsView> {
  final noteDatabase = NoteDatabase.instance;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final calificacionController = TextEditingController();

  bool esImportante = false;
  bool isNewNote = false;
  bool isLoading = false;
  DateTime? fechaSeleccionada;
  NoteModel? note;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    titleController.dispose();
    calificacionController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    setState(() => isLoading = true);

    if (widget.noteId == null) {
      setState(() {
        isNewNote = true;
        fechaSeleccionada = DateTime.now();
        isLoading = false;
      });
      return;
    }

    note = await noteDatabase.read(widget.noteId!);
    titleController.text = note!.titulo;
    calificacionController.text = note!.calificacion.toString();
    esImportante = note!.esImportante;
    fechaSeleccionada = note!.fechaCreacion;

    setState(() => isLoading = false);
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final newNote = NoteModel(
      id: note?.id,
      titulo: titleController.text.trim(),
      calificacion: double.tryParse(calificacionController.text) ?? 0.0,
      esImportante: esImportante,
      fechaCreacion: fechaSeleccionada ?? DateTime.now(),
    );

    isNewNote
        ? await noteDatabase.create(newNote)
        : await noteDatabase.update(newNote);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteNote() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro de que quieres eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && note?.id != null) {
      await noteDatabase.delete(note!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() => fechaSeleccionada = pickedDate);
    }
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewNote ? 'Nueva Nota' : 'Editar Nota'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!isNewNote)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
              tooltip: 'Eliminar nota',
            ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveNote,
            tooltip: 'Guardar nota',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildFormField(
                      'Titulo',
                      titleController,
                      validator: (value) => value?.trim().isEmpty ?? true
                          ? 'Este campo es requerido'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildFormField(
                      'Calificación (decimales)',
                      calificacionController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          // ignore: curly_braces_in_flow_control_structures
                          return 'Ingresa una calificación';
                        final numValue = double.tryParse(value!);
                        if (numValue == null) return 'Valor inválido';
                        if (numValue < 0 || numValue > 20)
                          // ignore: curly_braces_in_flow_control_structures
                          return 'Debe ser entre 0 y 20';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Marcar como importante',
                          style: TextStyle(fontSize: 16),
                        ),
                        value: esImportante,
                        onChanged: (value) =>
                            setState(() => esImportante = value),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fecha de creación',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fechaSeleccionada != null
                                        ? '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}'
                                        : 'No seleccionada',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _selectDate,
                              child: const Text('CAMBIAR FECHA'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
