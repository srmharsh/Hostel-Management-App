import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';

class BookingModel extends BaseModel {
  final String userId;
  final String roomId;
  final String bedId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String status; // pending, confirmed, cancelled, completed
  final double totalAmount;
  final String paymentStatus; // pending, paid, refunded
  final String paymentMethod;

  BookingModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.roomId,
    required this.bedId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
  });

  factory BookingModel.empty() {
    return BookingModel(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      roomId: '',
      bedId: '',
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now(),
      status: 'pending',
      totalAmount: 0.0,
      paymentStatus: 'pending',
      paymentMethod: '',
    );
  }

  factory BookingModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BookingModel(
      id: snapshot.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      roomId: data['roomId'] ?? '',
      bedId: data['bedId'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'roomId': roomId,
      'bedId': bedId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'status': status,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
    };
  }

  BookingModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? roomId,
    String? bedId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? status,
    double? totalAmount,
    String? paymentStatus,
    String? paymentMethod,
  }) {
    return BookingModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      bedId: bedId ?? this.bedId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
