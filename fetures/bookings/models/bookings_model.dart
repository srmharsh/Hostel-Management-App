import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';

class BookingsModel extends BaseModel {
  final String name;
  final String phoneNo;
  final int roomNO;
  final String roomId;
  final DateTime checkIn;
  final bool advancePaid;

  BookingsModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.phoneNo,
    required this.roomNO,
    required this.roomId,
    required this.checkIn,
    required this.advancePaid,
  });

  factory BookingsModel.empty() {
    return BookingsModel(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      name: '',
      phoneNo: '',
      roomNO: 0,
      roomId: '',
      checkIn: DateTime.now(),
      advancePaid: false,
    );
  }

  factory BookingsModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BookingsModel(
      id: snapshot.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      name: data['name'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      roomNO: data['roomNO'] ?? 0,
      roomId: data['roomId'] ?? '',
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      advancePaid: data['advancePaid'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'name': name,
      'phoneNo': phoneNo,
      'roomNO': roomNO,
      'roomId': roomId,
      'checkIn': Timestamp.fromDate(checkIn),
      'advancePaid': advancePaid,
    };
  }

  BookingsModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? phoneNo,
    int? roomNO,
    String? roomId,
    DateTime? checkIn,
    bool? advancePaid,
  }) {
    return BookingsModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      phoneNo: phoneNo ?? this.phoneNo,
      roomNO: roomNO ?? this.roomNO,
      roomId: roomId ?? this.roomId,
      checkIn: checkIn ?? this.checkIn,
      advancePaid: advancePaid ?? this.advancePaid,
    );
  }
} 