import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/contact_model.dart';

class ContactService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _contactsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");
    return _db.collection('users').doc(userId).collection('contacts');
  }

  // CREATE
  Future<void> addContact(String name, String email, String phone, String role) async {
    await _contactsRef.add({
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isFavorite': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ
  Stream<List<Contact>> getContacts() {
    return _contactsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // READ FAVORITES
  Stream<List<Contact>> getFavoriteContacts() {
    return _contactsRef
        .where('isFavorite', isEqualTo: true)
        .limit(3)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateContact(String id, String name, String email, String phone, String role) async {
    await _contactsRef.doc(id).update({
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    });
  }

  // IS FAVORITE
  Future<void> toggleFavorite(String id, bool currentStatus) async {
    await _contactsRef.doc(id).update({
      'isFavorite': !currentStatus,
    });
  }

  // DELETE
  Future<void> deleteContact(String id) async {
    await _contactsRef.doc(id).delete();
  }
}