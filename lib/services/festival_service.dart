import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showboxd/models/festival_model.dart';

class FestivalService {
  final _festivalCollection = FirebaseFirestore.instance.collection(
    "festivais",
  );

  Stream<List<FestivalModel>> getFestivals() {
    return _festivalCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FestivalModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  Future<void> addFestival(FestivalModel festival) async {
    await _festivalCollection.doc(festival.id).set(festival.toMap());
  }

  Future<void> updateFestival(FestivalModel festival) async {
    await _festivalCollection.doc(festival.id).update(festival.toMap());
  }
}
