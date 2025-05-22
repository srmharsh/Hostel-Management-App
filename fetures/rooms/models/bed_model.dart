import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';

class BedModel extends BaseModel {
  final String roomId;
  final String bedNumber;
  final String status; // available, occupied, maintenance
  final double price;

  BedModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.roomId,
    required this.bedNumber,
    required this.status,
    required this.price,
  });

  factory BedModel.empty() {
    return BedModel(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      roomId: '',
      bedNumber: '',
      status: 'available',
      price: 0.0,
    );
  }

  factory BedModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BedModel(
      id: snapshot.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      roomId: data['roomId'] ?? '',
      bedNumber: data['bedNumber'] ?? '',
      status: data['status'] ?? 'available',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'roomId': roomId,
      'bedNumber': bedNumber,
      'status': status,
      'price': price,
    };
  }

  BedModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomId,
    String? bedNumber,
    String? status,
    double? price,
  }) {
    return BedModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomId: roomId ?? this.roomId,
      bedNumber: bedNumber ?? this.bedNumber,
      status: status ?? this.status,
      price: price ?? this.price,
    );
  }
} 