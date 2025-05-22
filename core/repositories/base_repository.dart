import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';

abstract class BaseRepository<T extends BaseModel> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection;

  BaseRepository(this.collection);

  Future<T?> getById(String id) async {
    try {
      final doc = await _db.collection(collection).doc(id).get();
      if (doc.exists) {
        return fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  Future<List<T>> getAll() async {
    try {
      final querySnapshot = await _db.collection(collection).get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }

  Future<void> create(T model) async {
    try {
      final docRef = _db.collection(collection).doc();
      final data = model.toJson();
      data['id'] = docRef.id;
      await docRef.set(data);
    } catch (e) {
      print('Error creating document: $e');
      throw Exception('Failed to create document: $e');
    }
  }

  Future<void> update(T model) async {
    try {
      await _db.collection(collection).doc(model.id).update(model.toJson());
    } catch (e) {
      print('Error updating document: $e');
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.collection(collection).doc(id).delete();
    } catch (e) {
      print('Error deleting document: $e');
      throw Exception('Failed to delete document: $e');
    }
  }

  T fromSnapshot(DocumentSnapshot snapshot);
} 