import 'package:flutter/material.dart';
import 'note.dart';
import 'note_database.dart';
import 'note_details_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final noteDatabase = NoteDatabase.instance;
  List<NoteModel> notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    noteDatabase.close();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    notes = await noteDatabase.readAll();
    setState(() => _isLoading = false);
  }

  Future<void> _goToNoteDetails({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailsView(noteId: id)),
    );
    _loadNotes();
  }

  Widget _buildNoteItem(NoteModel note) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          note.titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: note.esImportante ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Calificación: ${note.calificacion}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Fecha: ${note.fechaCreacion.toString().split(' ')[0]}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: note.esImportante
            ? const Icon(Icons.star, color: Colors.amber)
            : null,
        onTap: () => _goToNoteDetails(id: note.id),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay notas aún',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para crear una nueva',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas del Curso'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadNotes,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notes.length,
                itemBuilder: (context, index) => _buildNoteItem(notes[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToNoteDetails(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white, // Color del ícono "+"
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}
