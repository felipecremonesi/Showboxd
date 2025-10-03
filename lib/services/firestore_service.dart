import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/show_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ShowModel>> getShows() {
    return _db.collection('shows').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ShowModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> addShow(ShowModel show) async {
    await _db.collection('shows').doc(show.id).set(show.toMap());
  }

  Future<void> updateShow(ShowModel show) async {
    await _db.collection('shows').doc(show.id).update(show.toMap());
  }
}
