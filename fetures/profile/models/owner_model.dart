import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/core/models/base_model.dart';

class OwnerModel extends BaseModel {
  final String ownerName;
  final String hostelName;
  final String emailAddress;
  final String mobileNumber;
  final String address;
  final String profilePicture;
  final int noOfRooms;
  final int noOfBeds;
  final int noOfVacancy;
  final bool isAccountSetupCompleted;

  OwnerModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.ownerName,
    required this.hostelName,
    required this.emailAddress,
    required this.mobileNumber,
    required this.address,
    required this.profilePicture,
    required this.noOfRooms,
    required this.noOfBeds,
    required this.noOfVacancy,
    required this.isAccountSetupCompleted,
  });

  factory OwnerModel.empty() {
    return OwnerModel(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerName: '',
      hostelName: '',
      emailAddress: '',
      mobileNumber: '',
      address: '',
      profilePicture: '',
      noOfRooms: 0,
      noOfBeds: 0,
      noOfVacancy: 0,
      isAccountSetupCompleted: false,
    );
  }

  factory OwnerModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OwnerModel(
      id: snapshot.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      ownerName: data['ownerName'] ?? '',
      hostelName: data['hostelName'] ?? '',
      emailAddress: data['emailAddress'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      address: data['address'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      noOfRooms: data['noOfRooms'] ?? 0,
      noOfBeds: data['noOfBeds'] ?? 0,
      noOfVacancy: data['noOfVacancy'] ?? 0,
      isAccountSetupCompleted: data['isAccountSetupCompleted'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'ownerName': ownerName,
      'hostelName': hostelName,
      'emailAddress': emailAddress,
      'mobileNumber': mobileNumber,
      'address': address,
      'profilePicture': profilePicture,
      'noOfRooms': noOfRooms,
      'noOfBeds': noOfBeds,
      'noOfVacancy': noOfVacancy,
      'isAccountSetupCompleted': isAccountSetupCompleted,
    };
  }

  OwnerModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    String? hostelName,
    String? emailAddress,
    String? mobileNumber,
    String? address,
    String? profilePicture,
    int? noOfRooms,
    int? noOfBeds,
    int? noOfVacancy,
    bool? isAccountSetupCompleted,
  }) {
    return OwnerModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerName: ownerName ?? this.ownerName,
      hostelName: hostelName ?? this.hostelName,
      emailAddress: emailAddress ?? this.emailAddress,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      noOfRooms: noOfRooms ?? this.noOfRooms,
      noOfBeds: noOfBeds ?? this.noOfBeds,
      noOfVacancy: noOfVacancy ?? this.noOfVacancy,
      isAccountSetupCompleted: isAccountSetupCompleted ?? this.isAccountSetupCompleted,
    );
  }
}
