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
    Stream<QuerySnapshot> getNoteStream(){
      final notesStream = notes.orderBy('timestamp', descending: true).snapshots();

      return notesStream;
    }

  // Update: update note given i a doc id
  Future<void> updatesNote( String docID, String newNote){
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete: Given notes given a doc id
   Future<void> deleteNote(String docID){
    return notes.doc(docID).delete();

}
}