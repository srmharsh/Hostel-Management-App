import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/repositories/base_repository.dart';
import 'package:hostel_management_app/fetures/rooms/models/room_model.dart';

class RoomRepository extends BaseRepository<RoomModel> {
  RoomRepository() : super('rooms');

  @override
  RoomModel fromSnapshot(DocumentSnapshot snapshot) {
    return RoomModel.fromSnapshot(snapshot);
  }

  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('status', isEqualTo: 'available')
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting available rooms: $e');
      return [];
    }
  }

  Future<List<RoomModel>> getRoomsByFloor(int floor) async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('floor', isEqualTo: floor)
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting rooms by floor: $e');
      return [];
    }
  }

  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await _db.collection(collection).doc(roomId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating room status: $e');
      throw Exception('Failed to update room status: $e');
    }
  }

  Future<void> updateRoomOccupancy(String roomId, int currentOccupancy) async {
    try {
      await _db.collection(collection).doc(roomId).update({
        'currentOccupancy': currentOccupancy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating room occupancy: $e');
      throw Exception('Failed to update room occupancy: $e');
    }
  }
} 