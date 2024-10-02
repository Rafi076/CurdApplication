import 'package:basic_curdapplication/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker package
import 'dart:io'; // For handling image files

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

  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; // To store the selected image

  // Boolean for tracking dark mode
  bool isDarkMode = false;

  // Open a dialog box to add or update a note
  void openNotebox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image box
            GestureDetector(
              onTap: () async {
                final XFile? pickedFile =
                await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path); // Store the selected image
                  });
                }
              },
              child: _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.add_a_photo, size: 50),
              ),
            ),
            const SizedBox(height: 10),
            // Note input
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Enter your note here',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // Add a new note with the image (if selected)
                firestoreService.addNotes(textController.text);
              } else {
                // Update an existing note with the image (if selected)
                firestoreService.updatesNote(docID, textController.text);
              }

              // Clear the text controller after saving or updating
              textController.clear();
              _selectedImage = null; // Reset selected image

              // Close the dialog box
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          ElevatedButton(
            onPressed: () {
              textController.clear();
              _selectedImage = null; // Reset selected image
              Navigator.pop(context); // Close dialog without saving
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Toggle between light and dark modes
  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Add Motives',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        ),
        // Floating action button to add a new note
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Add new note button
            FloatingActionButton(
              onPressed: () => openNotebox(null), // Pass null for adding a new note
              child: const Icon(Icons.add),
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue,
              shape: const CircleBorder(),
            ),
            const SizedBox(height: 10),
            // Toggle dark mode button
            FloatingActionButton(
              onPressed: toggleDarkMode, // Toggle dark mode
              child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue,
              shape: const CircleBorder(),
            ),
          ],
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

                  // Display each note inside a shadowed container
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          noteText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => openNotebox(docID), // Open dialog to update the note
                              icon: const Icon(Icons.edit),
                            ),

                            // Delete
                            IconButton(
                              onPressed: () => firestoreService.deleteNote(docID), // Delete the note
                              icon: const Icon(Icons.clear),
                            ),
                          ],
                        ),
                      ),
                    ),
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
      ),
    );
  }
}
