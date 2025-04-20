import 'package:flutter/material.dart';
import 'package:notes_flutter/NoteShowScreen.dart';
import 'AddNoteScreen.dart';
import 'dart:convert';
import 'package:notes_flutter/DbHelper.dart';

DbHelper d = DbHelper();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notes",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _notes = [];
  List<Map<String,dynamic>> _filterNotes=[];
  List<Map<String,dynamic>> _todoLists=[];
  String _searchQuery= '';

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes([String query= '']) async {
    final data = await d.getNotes(query: query);
    setState(() {
      _notes = data;
      _filterNotes=data;
    });
  }
  void _applySearchFilter() {
    setState(() {
      _filterNotes = _notes.where((note) {
        final title = (note['title'] ?? '').toLowerCase();
        final content = (note['content'] ?? '').toLowerCase();
        return title.contains(_searchQuery) || content.contains(_searchQuery);
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes  '),
        centerTitle: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Note Here.....",
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                 _searchQuery=value.toLowerCase();
                 loadNotes(_searchQuery);
                });
              },

            ),
          ),
          Expanded(
            child: (_notes.isEmpty && _todoLists.isEmpty)
                ? Center(
              child: Text(
                "No Data Available Right Now.....!",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
                : ListView(
              children: [
                // Notes
                ..._notes.map((note) => Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    onTap: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NoteDetailScreen(note: note, isTodo: false),
                        ),
                      );
                      if (result == true) loadNotes();
                    },
                    title: Text(note['title'] ?? ''),
                    subtitle: Text(
                      note['content'] ?? '',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      note['date'].toString().substring(0, 10),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                )),

                // To-Do Lists

              ],
            ),
          ),
        ],
      ),
    /*  floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "What You Want To ADD?",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddNoteScreen()),
                        );
                        loadNotes();
                      },
                      icon: Icon(Icons.note_add),
                      label: Text("Add New Note"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddToDoListScreen()),
                        );
                        // No need to refresh notes because to-do lists aren't shown
                      },
                      icon: Icon(Icons.checklist),
                      label: Text("Add Checklist"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),*/
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );

          if (result == true) {
            loadNotes(); // Refresh notes list after adding
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
