// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostel_management_app/fetures/rooms/models/room_model.dart';

class RoomsRepository with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

//------------------------------------------------------------------------------fetch Rooms

  Future<List<RoomModel>> fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _db
          .collection('Owners')
          .doc(user.uid)
          .collection('Rooms')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final rooms = snapshot.docs
          .map((documentSnapshot) => RoomModel.fromSnapshot(documentSnapshot))
          .toList();
      return rooms;
    } catch (e) {
      print('Error fetching rooms: $e');
      throw Exception('Failed to fetch rooms: ${e.toString()}');
    }
  }

  //----------------------------------------------------------------------------fetch single room

  Future<RoomModel?> fetchSingleRoom({required String roomId}) async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null || userId.isEmpty) {
        throw Exception("Unable to find user information, try again later");
      }

      final result = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Rooms")
          .doc(roomId)
          .get();

      if (result.exists) {
        return RoomModel.fromSnapshot(result);
      }
    } catch (e) {
      print("Error: $e");

      rethrow;
    }
    return null;
  }

  Future<RoomModel?> getRoomByRoomNo(int roomNo) async {
    try {
      final userId = _auth.currentUser!.uid;
      final querySnapshot = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Rooms")
          .where("RoomNo", isEqualTo: roomNo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Room with the same number exists
        final roomData = querySnapshot.docs.first;
        return RoomModel.fromSnapshot(roomData);
      } else {
        // Room with the given number does not exist
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//------------------------------------------------------------------------------Add new Room

  addRoom(RoomModel room) async {
    try {
      final userId = _auth.currentUser!.uid;
      if (userId.isEmpty) {
        throw Exception("User not authenticated");
      }
      
      final docRef = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Rooms")
          .add(room.toJson());
          
      // Verify the room was added by fetching it
      final addedRoom = await docRef.get();
      if (!addedRoom.exists) {
        throw Exception("Failed to add room");
      }
      
      return docRef.id;
    } catch (e) {
      print("Error adding room: $e");
      rethrow;
    }
  }

  //----------------------------------------------------------------------------Update room

  Future<void> updadatRoom(RoomModel room) async {
    final userId = _auth.currentUser!.uid;
    try {
      await _db
          .collection("Owners")
          .doc(userId)
          .collection("Rooms")
          .doc(room.id)
          .update(room.toJson());
    } catch (e) {
      print("Somthing went wrong");
    }
  }

  //----------------------------------------------------------------------------update single field

  Future<void> updateSingleField(
      {required Map<String, dynamic> json, required String roomId}) async {
    try {
      final currentUser = _auth.currentUser;
      await _db
          .collection("Owners")
          .doc(currentUser!.uid)
          .collection("Rooms")
          .doc(roomId)
          .update(json);
    } catch (e) {
      print("Somthis went wrong");
      print(e);
    }
  }

  //--------------------------------------------------------------------------- Delete a room

  Future<void> deleteRoom(String roomId) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _db
          .collection("Owners")
          .doc(userId)
          .collection("Rooms")
          .doc(roomId)
          .delete();
    } catch (e) {
      print("somthing went wrong");
    }
  }
}
