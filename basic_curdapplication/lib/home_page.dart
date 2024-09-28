import 'package:basic_curdapplication/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //3 firestore..
  final FirestoreService firestoreService = FirestoreService();

  //2 Text controller
  final TextEditingController textController = TextEditingController();

  //1 Open a dialog box to add a note
  void openNotebox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a note'),
        content: TextField(

          //2 Text controller
          controller: textController,
        ),
        actions: [
          // Button to save the note
          ElevatedButton(
            onPressed: () {
              //3 Add functionality to save or handle the note
              firestoreService.addNotes(textController.text);

              // after add clear the text controller
              textController.clear();

              // after clear close the box
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
      // Action button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 35),
        child: FloatingActionButton(
          onPressed: openNotebox,
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue, // Sets the color to blue
          shape: const CircleBorder(), // Ensures the button is circular (default shape)
        ),
      ),
    );
  }
}
