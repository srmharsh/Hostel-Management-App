import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/repositories/base_repository.dart';
import 'package:hostel_management_app/fetures/rooms/models/bed_model.dart';

class BedRepository extends BaseRepository<BedModel> {
  BedRepository() : super('beds');

  @override
  BedModel fromSnapshot(DocumentSnapshot snapshot) {
    return BedModel.fromSnapshot(snapshot);
  }

  Future<List<BedModel>> getBedsByRoom(String roomId) async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('roomId', isEqualTo: roomId)
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting beds by room: $e');
      return [];
    }
  }

  Future<List<BedModel>> getAvailableBeds() async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('status', isEqualTo: 'available')
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting available beds: $e');
      return [];
    }
  }

  Future<void> updateBedStatus(String bedId, String status) async {
    try {
      await _db.collection(collection).doc(bedId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating bed status: $e');
      throw Exception('Failed to update bed status: $e');
    }
  }

  Future<void> updateBedPrice(String bedId, double price) async {
    try {
      await _db.collection(collection).doc(bedId).update({
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating bed price: $e');
      throw Exception('Failed to update bed price: $e');
    }
  }
} 