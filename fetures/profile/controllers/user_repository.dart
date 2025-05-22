// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';
import 'package:hostel_management_app/core/repositories/base_repository.dart';
import 'package:hostel_management_app/fetures/profile/models/owner_model.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository extends BaseRepository<OwnerModel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserRepository() : super('Owners');

  @override
  OwnerModel fromSnapshot(DocumentSnapshot snapshot) {
    return OwnerModel.fromSnapshot(snapshot);
  }

  Future<OwnerModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      
      return await getById(currentUser.uid);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');
      
      await _db.collection(collection).doc(currentUser.uid).update(data);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String?> uploadImage(String path, XFile image) async {
    try {
      if (image.path.isEmpty) {
        throw Exception('No image selected');
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename with timestamp and ensure .jpg extension
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${image.name}';
      final fileNameWithJpg = fileName.endsWith('.jpg') ? fileName : '$fileName.jpg';
      
      // Create the storage reference with the correct path
      final storagePath = 'Owners/Images/Profile/${user.uid}/$fileNameWithJpg';
      print('Attempting to upload to path: $storagePath');
      
      final storageRef = _storage.ref().child(storagePath);
      
      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': image.path},
      );
      
      try {
        // Upload the file
        final uploadTask = await storageRef.putFile(
          File(image.path),
          metadata,
        );
        
        if (uploadTask.state == TaskState.success) {
          // Get the download URL
          final downloadUrl = await storageRef.getDownloadURL();
          print('Image uploaded successfully. URL: $downloadUrl');
          return downloadUrl;
        } else {
          print('Upload task state: ${uploadTask.state}');
          throw Exception('Failed to upload image: ${uploadTask.state}');
        }
      } on FirebaseException catch (e) {
        print('Firebase Storage error code: ${e.code}');
        print('Firebase Storage error message: ${e.message}');
        print('Firebase Storage error details: ${e.toString()}');
        
        if (e.code == 'object-not-found') {
          throw Exception('Storage path not found. Please check Firebase Storage rules and path configuration. Path attempted: $storagePath');
        } else if (e.code == 'unauthorized') {
          throw Exception('Unauthorized access. Please check Firebase Storage rules.');
        } else if (e.code == 'canceled') {
          throw Exception('Upload was canceled.');
        }
        throw Exception('Firebase Storage error: ${e.message}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<OwnerModel?> fetchOwnerRecords() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _db.collection(collection).doc(currentUser.uid).get();
      if (!doc.exists) return null;

      return OwnerModel.fromSnapshot(doc);
    } catch (e) {
      print('Error fetching owner records: $e');
      return null;
    }
  }

  Future<void> saveUserRecords(OwnerModel owner) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _db.collection(collection).doc(currentUser.uid).set(owner.toJson());
    } catch (e) {
      print('Error saving user records: $e');
      rethrow;
    }
  }

  Future<void> updateOwnerRecords(OwnerModel owner) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _db.collection(collection).doc(currentUser.uid).update(owner.toJson());
    } catch (e) {
      print('Error updating owner records: $e');
      rethrow;
    }
  }

  Future<void> deleteOwnerRecords(String userId) async {
    try {
      await _db.collection(collection).doc(userId).delete();
    } catch (e) {
      print('Error deleting owner records: $e');
      rethrow;
    }
  }

  Future<void> accountSetup(Map<String, dynamic> data) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _db.collection(collection).doc(currentUser.uid).update(data);
    } catch (e) {
      print('Error in account setup: $e');
      rethrow;
    }
  }
}
