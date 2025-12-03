import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String city;
  final String state;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String observations;
  final String status;

  Project({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.observations,
    required this.status,
  });

  factory Project.fromMap(Map<String, dynamic> data, String id) {
    return Project(
      id: id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      observations: data['observations'] ?? '',
      status: data['status'] ?? 'ongoing',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'state': state,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'description': description,
      'observations': observations,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}