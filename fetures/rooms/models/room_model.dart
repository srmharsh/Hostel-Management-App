import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';

class RoomModel extends BaseModel {
  final int roomNo;
  final int rent;
  final int vacancy;
  final List<String> residents;
  final List<int> facilities;
  final String roomNumber;
  final int floor;
  final int capacity;
  final int currentOccupancy;
  final double price;
  final String status; // available, occupied, maintenance
  final String type; // single, double, triple, etc.
  final List<String> amenities;

  RoomModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.roomNo,
    required this.rent,
    required this.vacancy,
    required this.residents,
    required this.facilities,
    required this.roomNumber,
    required this.floor,
    required this.capacity,
    required this.currentOccupancy,
    required this.price,
    required this.status,
    required this.type,
    required this.amenities,
  });

  factory RoomModel.empty() {
    return RoomModel(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      roomNo: 0,
      rent: 0,
      vacancy: 0,
      residents: [],
      facilities: [],
      roomNumber: '',
      floor: 0,
      capacity: 0,
      currentOccupancy: 0,
      price: 0.0,
      status: 'available',
      type: 'single',
      amenities: [],
    );
  }

  factory RoomModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return RoomModel(
      id: snapshot.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      roomNo: data['roomNo'] ?? 0,
      rent: data['rent'] ?? 0,
      vacancy: data['vacancy'] ?? 0,
      residents: List<String>.from(data['residents'] ?? []),
      facilities: List<int>.from(data['facilities'] ?? []),
      roomNumber: data['roomNumber'] ?? '',
      floor: data['floor'] ?? 0,
      capacity: data['capacity'] ?? 0,
      currentOccupancy: data['currentOccupancy'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'available',
      type: data['type'] ?? 'single',
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'roomNo': roomNo,
      'rent': rent,
      'vacancy': vacancy,
      'residents': residents,
      'facilities': facilities,
      'roomNumber': roomNumber,
      'floor': floor,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'price': price,
      'status': status,
      'type': type,
      'amenities': amenities,
    };
  }

  RoomModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? roomNo,
    int? rent,
    int? vacancy,
    List<String>? residents,
    List<int>? facilities,
    String? roomNumber,
    int? floor,
    int? capacity,
    int? currentOccupancy,
    double? price,
    String? status,
    String? type,
    List<String>? amenities,
  }) {
    return RoomModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomNo: roomNo ?? this.roomNo,
      rent: rent ?? this.rent,
      vacancy: vacancy ?? this.vacancy,
      residents: residents ?? this.residents,
      facilities: facilities ?? this.facilities,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      price: price ?? this.price,
      status: status ?? this.status,
      type: type ?? this.type,
      amenities: amenities ?? this.amenities,
    );
  }
}
