import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/project_model.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _projectsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");
    return _db.collection('users').doc(userId).collection('projects');
  }

  // CREATE
  Future<void> addProject(Project project) async {
    await _projectsRef.add(project.toMap());
  }

  // UPDATE
  Future<void> updateProject(Project project) async {
    await _projectsRef.doc(project.id).update(project.toMap());
  }

  // DELETE
  Future<void> deleteProject(String id) async {
    await _projectsRef.doc(id).delete();
  }

  // READ ALL
  Stream<List<Project>> getProjects() {
    return _projectsRef
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // READ - na dashboard
  Stream<List<Project>> getDashboardProjects() {
    return _projectsRef
        .where('status', isEqualTo: 'ongoing')
        .limit(4)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}