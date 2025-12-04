import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String description;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
  });

  factory Event.fromMap(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}