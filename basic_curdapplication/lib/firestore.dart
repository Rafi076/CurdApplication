import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  // get collection of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //Create: add a new notes
  Future<void> addNotes(String note){
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // Read: get notes from database

  // Update: update note given i a doc id

  // Delete: Given notes given a doc id
}