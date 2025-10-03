import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showboxd/models/show_model.dart';

class WishlistService {
  final CollectionReference _wishlistRef = FirebaseFirestore.instance
      .collection('wishlists');

  Future<void> addShowToWishlist(String userId, String showId) async {
    final doc = _wishlistRef.doc(userId);

    await doc.set({
      'shows': FieldValue.arrayUnion([showId]),
    }, SetOptions(merge: true));
  }

  Future<void> removeShowFromWishlist(String userId, String showId) async {
    final doc = _wishlistRef.doc(userId);

    await doc.update({
      'shows': FieldValue.arrayRemove([showId]),
    });
  }

  Stream<List<String>> getWishlist(String userId) {
    return _wishlistRef.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data() as Map<String, dynamic>;
      return List<String>.from(data['shows'] ?? []);
    });
  }

  Future<ShowModel?> getShowById(String showId) async {
    final doc = await FirebaseFirestore.instance
        .collection("shows")
        .doc(showId)
        .get();

    if (!doc.exists) return null;

    return ShowModel.fromMap(doc.data()!);
  }
}
