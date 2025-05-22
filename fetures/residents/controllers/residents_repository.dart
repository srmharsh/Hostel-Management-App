// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_management_app/fetures/residents/models/resident_model.dart';

class ResidentsRepository {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //----------------------------------------------------------------------------Fetch Resident Detailes

  Future<List<ResidentModel>> fetchData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception("Unable to find user information, try again later");
      }

      final result = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .get();

      final residentModel = result.docs
          .map((documentSnapshot) =>
              ResidentModel.fromDocumentSnapshot(documentSnapshot))
          .toList();

      return residentModel;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  //----------------------------------------------------------------------------fetchResident detailes with id

  Future<List<ResidentModel>> fetchResidentsByIds(
      List<String> residentIds) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception("Unable to find user information, try again later");
      }

      final List<ResidentModel> residentModels = [];

      for (String residentId in residentIds) {
        final result = await _db
            .collection("Owners")
            .doc(userId)
            .collection("Residents")
            .doc(residentId)
            .get();

        if (result.exists) {
          final residentModel = ResidentModel.fromDocumentSnapshot(result);
          residentModels.add(residentModel);
        } else {}
      }

      return residentModels;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------Add Residents

  Future<String> addResidents(ResidentModel resident) async {
    try {
      print("Starting addResidents in repository...");
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        print("No user ID found");
        throw Exception("Unable to find user information, try again later");
      }

      print("User ID: $userId");
      print("Resident data: ${resident.toJson()}");

      // Initialize database structure first
      await initializeDatabaseStructure();

      print("Adding resident to Firestore...");
      // Create a new document reference
      DocumentReference docRef = _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .doc(); // Let Firestore generate the ID

      // Set the data with the generated ID
      await docRef.set({
        ...resident.toJson(),
        "id": docRef.id, // Add the document ID to the data
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("Resident added successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error in addResidents: $e");
      rethrow;
    }
  }

//------------------------------------------------------------------------------delete Resident

  Future<void> deleteResident(String residentId) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .doc(residentId)
          .delete();
    } catch (e) {
      print("somthing went wrong $e");
      rethrow;
    }
  }

//------------------------------------------------------------------------------delete list of documents
  Future<void> deleteListOfResidents(List<String> residentIds) async {
    try {
      final userId = _auth.currentUser!.uid;

      for (String residentId in residentIds) {
        await _db
            .collection("Owners")
            .doc(userId)
            .collection("Residents")
            .doc(residentId)
            .delete();
      }
    } catch (e) {
      print("Something went wrong $e");
      rethrow;
    }
  }

// -----------------------------------------------------------------------------delete with room no
  Future<void> deleteResidentsByRoomNo(int roomNo) async {
    try {
      final userId = _auth.currentUser!.uid;

      // Query the collection to find all residents with the specified roomNo
      QuerySnapshot residentsSnapshot = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .where("RoomNo", isEqualTo: roomNo)
          .get();

      // Delete all matching documents
      for (QueryDocumentSnapshot residentDoc in residentsSnapshot.docs) {
        await _db
            .collection("Owners")
            .doc(userId)
            .collection("Residents")
            .doc(residentDoc.id)
            .delete();
      }
    } catch (e) {
      print("Something went wrong: $e");
      rethrow;
    }
  }

  //----------------------------------------------------------------------------update resident Detailes

  Future<void> updateResident(ResidentModel resident) async {
    final userId = _auth.currentUser!.uid;
    try {
      await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .doc(resident.id)
          .update(resident.toJson());
    } catch (e) {
      print("Somthing went wrong : $e");
      rethrow;
    }
  }

//------------------------------------------------------------------------------update romm no only

  Future<void> updateResidentsRoomNo(int oldRoomNo, int newRoomNo) async {
    final userId = _auth.currentUser!.uid;

    try {
      // Query the collection to find all residents with the oldRoomNo
      QuerySnapshot residentsSnapshot = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .where("RoomNo", isEqualTo: oldRoomNo)
          .get();

      // Update the roomNo field for each matching resident
      for (QueryDocumentSnapshot residentDoc in residentsSnapshot.docs) {
        await _db
            .collection("Owners")
            .doc(userId)
            .collection("Residents")
            .doc(residentDoc.id)
            .update({"RoomNo": newRoomNo});
      }
    } catch (e) {
      print("Something went wrong: $e");
      rethrow;
    }
  }

//------------------------------------------------------------------------------update Singlefield
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    final userId = _auth.currentUser!.uid;

    try {
      await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .doc(id)
          .update(json);
    } catch (e) {
      print("Something went wrong: $e");
      rethrow;
    }
  }

  // Add this new method
  Future<void> initializeDatabaseStructure() async {
    try {
      print("Starting database initialization...");
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        print("No user ID found");
        throw Exception("Unable to find user information, try again later");
      }

      print("Checking Owners collection...");
      // Check if the Owners collection exists
      final ownersCollection = await _db.collection("Owners").get();
      if (ownersCollection.docs.isEmpty) {
        print("Creating Owners collection...");
        // Create the Owners collection with a dummy document
        await _db.collection("Owners").doc("dummy").set({
          "createdAt": FieldValue.serverTimestamp(),
        });
        // Delete the dummy document
        await _db.collection("Owners").doc("dummy").delete();
      }

      print("Checking Owner document...");
      // Check if the Owner document exists
      final ownerDoc = await _db.collection("Owners").doc(userId).get();
      if (!ownerDoc.exists) {
        print("Creating Owner document...");
        await _db.collection("Owners").doc(userId).set({
          "createdAt": FieldValue.serverTimestamp(),
          "userId": userId,
          "name": _auth.currentUser?.displayName ?? "",
          "email": _auth.currentUser?.email ?? "",
        });
      }

      print("Checking Residents subcollection...");
      // Check if the Residents subcollection exists
      final residentsCollection = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Residents")
          .get();
      
      if (residentsCollection.docs.isEmpty) {
        print("Creating Residents subcollection...");
        // Create a dummy resident to initialize the subcollection
        await _db
            .collection("Owners")
            .doc(userId)
            .collection("Residents")
            .doc("dummy")
            .set({
          "createdAt": FieldValue.serverTimestamp(),
        });
        // Delete the dummy document
        await _db
            .collection("Owners")
            .doc(userId)
            .collection("Residents")
            .doc("dummy")
            .delete();
      }

      print("Database structure initialized successfully");
    } catch (e) {
      print("Error initializing database structure: $e");
      rethrow;
    }
  }

  // Add this new method to fetch bookings and convert them to residents
  Future<List<ResidentModel>> fetchResidentsFromBookings() async {
    try {
      print("Fetching residents from bookings...");
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception("Unable to find user information, try again later");
      }

      // Fetch all bookings
      final bookingsSnapshot = await _db
          .collection("Owners")
          .doc(userId)
          .collection("Bookings")
          .where("status", isEqualTo: "confirmed") // Only get confirmed bookings
          .get();

      print("Found ${bookingsSnapshot.docs.length} confirmed bookings");

      List<ResidentModel> residents = [];
      for (var bookingDoc in bookingsSnapshot.docs) {
        final bookingData = bookingDoc.data();
        
        // Create a resident model from booking data
        final resident = ResidentModel(
          id: bookingDoc.id,
          name: bookingData["name"] ?? "",
          profilePic: bookingData["profilePic"] ?? "",
          roomNo: bookingData["roomNO"] ?? 0,
          roomId: bookingData["roomId"] ?? "",
          phone: bookingData["phoneNo"] ?? "",
          email: bookingData["email"] ?? "",
          address: bookingData["address"] ?? "",
          emargencyContact: bookingData["emergencyContact"] ?? "",
          purposOfStay: bookingData["purpose"] ?? "",
          checkIn: (bookingData["checkInDate"] as Timestamp).toDate(),
          checkOut: (bookingData["checkOutDate"] as Timestamp).toDate(),
          nextRentDate: (bookingData["checkInDate"] as Timestamp).toDate().add(const Duration(days: 30)),
          isRentPaid: bookingData["paymentStatus"] == "paid",
        );

        residents.add(resident);
      }

      print("Converted ${residents.length} bookings to residents");
      return residents;
    } catch (e) {
      print("Error fetching residents from bookings: $e");
      rethrow;
    }
  }
}
