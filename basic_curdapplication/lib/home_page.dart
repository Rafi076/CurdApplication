import 'package:basic_curdapplication/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Firestore service instance
  final FirestoreService firestoreService = FirestoreService();

  // Text controller
  final TextEditingController textController = TextEditingController();

  // Open a dialog box to add or update a note
  void openNotebox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a note'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // Add a new note
                firestoreService.addNotes(textController.text);
              } else {
                // Update an existing note
                firestoreService.updatesNote(docID, textController.text);
              }

              // Clear the text controller after saving or updating
              textController.clear();

              // Close the dialog box
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Motives',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      // Floating action button to add a new note
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNotebox(null), // Pass null for adding a new note
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNoteStream(),
        builder: (context, snapshot) {
          // If we have data, get all the documents
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // Display the notes in a ListView
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // Get each individual document
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // Get note from each document
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // Display each note in a ListTile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        onPressed: () => openNotebox(docID), // Open dialog to update the note
                        icon: const Icon(Icons.settings),
                      ),

                      //delete
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),// Open dialog to update the note
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  )
                );
              },
            );
          } else {
            return const Center(
              child: Text("No notes found."),
            );
          }
        },
      ),
    );
  }
}
