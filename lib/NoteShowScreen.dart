import 'package:flutter/material.dart';
import 'package:notes_flutter/DbHelper.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  NoteDetailScreen({required this.note, required bool isTodo});

  @override
  State<NoteDetailScreen> createState() => NoteDetailScreenState();
}

class NoteDetailScreenState extends State<NoteDetailScreen> {
  final DbHelper _db = DbHelper();

  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title']);
    _contentController = TextEditingController(text: widget.note['content']);
  }

  void _updateNote() async {
    if (_formKey.currentState!.validate()) {
      await _db.updateNote(
        widget.note['id'], // ✅ correct method
        _titleController.text.trim(),
        _contentController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note updated successfully")),
      );

      setState(() {
        isEditing = false;
      });

      Navigator.pop(context, true); // ✅ return true to refresh on HomeScreen
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Note"),
        content: Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await _db.deleteNote(widget.note['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Note deleted")),
              );
              Navigator.pop(context, true); // ✅ refresh main screen
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Detail"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Edit') {
                setState(() {
                  isEditing = true;
                });
              } else if (value == 'Delete') {
                _deleteNote();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Edit', child: Text('Edit')),
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Title required' : null,
              ),
              SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  readOnly: !isEditing,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Content required' : null,
                ),
              ),
              if (isEditing)
                ElevatedButton(
                  onPressed: _updateNote,
                  child: Text("Update"),
                )
            ],
          ),
        ),
      ),
    );
  }
}
