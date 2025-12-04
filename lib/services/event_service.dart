import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _eventsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");
    return _db.collection('users').doc(userId).collection('events');
  }

  Future<void> addEvent(Event event) async {
    await _eventsRef.add(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _eventsRef.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _eventsRef.doc(id).delete();
  }

  // Get all events
  Stream<List<Event>> getEvents() {
    return _eventsRef
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // seleciona os 3 proximos eventos
  Stream<List<Event>> getUpcomingEvents() {
    final now = DateTime.now();
    // Reset
    final today = DateTime(now.year, now.month, now.day);

    return _eventsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy('date')
        .limit(3)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}