import 'package:flutter/material.dart';
import 'package:notes_flutter/DbHelper.dart';

final DbHelper _d = DbHelper();

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titletextControl = TextEditingController();
  final TextEditingController contentContro = TextEditingController();

  void _saveNote() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == true) {
      final title = titletextControl.text.trim();
      final content = contentContro.text.trim();

      await _d.insertNote(title, content);
      titletextControl.clear();
      contentContro.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note Added Successfully!")),
      );

      Navigator.pop(context,true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Note"),
        backgroundColor: Colors.indigo,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView( // ✅ Use scroll view to prevent overflow and help with validation
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: titletextControl,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please Enter Title Here!';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: contentContro,
                 maxLines: 20, // ✅ Instead of Expanded, use fixed height
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "Enter Content Here...",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please Enter Content Here!';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        backgroundColor: Colors.blue,
        child: Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
