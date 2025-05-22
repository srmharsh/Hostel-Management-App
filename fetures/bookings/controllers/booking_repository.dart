import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/repositories/base_repository.dart';
import 'package:hostel_management_app/fetures/bookings/models/booking_model.dart';

class BookingRepository extends BaseRepository<BookingModel> {
  BookingRepository() : super('bookings');

  @override
  BookingModel fromSnapshot(DocumentSnapshot snapshot) {
    return BookingModel.fromSnapshot(snapshot);
  }

  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .orderBy('checkInDate', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting bookings by user: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getBookingsByRoom(String roomId) async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('roomId', isEqualTo: roomId)
          .orderBy('checkInDate', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting bookings by room: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getBookingsByStatus(String status) async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where('status', isEqualTo: status)
          .orderBy('checkInDate', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting bookings by status: $e');
      return [];
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _db.collection(collection).doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }

  Future<void> updatePaymentStatus(String bookingId, String status) async {
    try {
      await _db.collection(collection).doc(bookingId).update({
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _db
          .collection(collection)
          .where('checkInDate', isGreaterThan: now)
          .where('status', isEqualTo: 'confirmed')
          .orderBy('checkInDate')
          .get();
      return querySnapshot.docs.map((doc) => fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting upcoming bookings: $e');
      return [];
    }
  }
} 