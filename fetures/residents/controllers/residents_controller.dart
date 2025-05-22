// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hostel_management_app/fetures/bookings/controllers/bookings_controller.dart';
import 'package:hostel_management_app/commens/functions/connection_checher.dart';
import 'package:hostel_management_app/fetures/residents/controllers/residents_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_management_app/fetures/rooms/controllers/rooms_repository.dart';
import 'package:hostel_management_app/fetures/profile/controllers/user_repository.dart';
import 'package:hostel_management_app/fetures/bookings/models/booking_model.dart';
import 'package:hostel_management_app/fetures/profile/models/owner_model.dart';
import 'package:hostel_management_app/fetures/residents/models/resident_model.dart';
import 'package:hostel_management_app/fetures/rooms/models/room_model.dart';
import 'package:hostel_management_app/fetures/residents/screens/residents_adding_form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hostel_management_app/fetures/bookings/models/bookings_model.dart';

class ResidentsController with ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final purposeController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNoController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final emargencyContactController = TextEditingController();
  final checkInDateController = TextEditingController();
  final checkOutDateController = TextEditingController();

  final ResidentsRepository residentsRepository = ResidentsRepository();
  final ConnectionChecker connectionController = ConnectionChecker();
  final BookingsController bookingsController = BookingsController();
  final RoomsRepository roomController = RoomsRepository();
  final UserRepository ownerRepository = UserRepository();
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<ResidentModel> allResidents = [];
  List<ResidentModel> residents = [];
  List<RoomModel> vacantRooms = [];
  List<String> vacantRoomNoList = [];
  String? selectedRoom = "0";
  String? selectedRoomId = "";
  DateTime? checkInDate;
  DateTime? checkOutDate;
  File? selectedImage;
  String oldImage = "";
  String? imageUrl;
  String? editingRoomId;
  String? editingResidentId;
  ResidentModel? editingResidnt;
  BookingsModel? addingBooking;
  bool isAddingaBookedResident = false;
  int? oldRoomNo;
  bool isEditing = false;
  bool isResidentsLoading = false;

  List<String> filters = [
    "All Residents",
    "Rent Penting",
  ];
  String selctedFilter = "All Residents";

// -----------------------------------------------------------------------------Fetch Resident detailes
  Future<void> fetchResidents() async {
    try {
      isResidentsLoading = true;
      notifyListeners();

      // Initialize database structure first
      await residentsRepository.initializeDatabaseStructure();

      // Fetch regular residents
      List<ResidentModel> regularResidents = await residentsRepository.fetchData();
      print("Fetched ${regularResidents.length} regular residents");

      // Fetch residents from bookings
      List<ResidentModel> bookingResidents = await residentsRepository.fetchResidentsFromBookings();
      print("Fetched ${bookingResidents.length} residents from bookings");

      // Combine both lists
      allResidents = [...regularResidents, ...bookingResidents];
      
      // Sort by room number
      allResidents.sort((a, b) => a.roomNo.compareTo(b.roomNo));
      residents = allResidents;

      print("Total residents: ${allResidents.length}");
    } catch (e) {
      print("Error fetching residents: $e");
      rethrow;
    } finally {
      isResidentsLoading = false;
      notifyListeners();
    }
  }

//------------------------------------------------------------------------------Fetch Vacant Rooms
  fetchVacantRooms() async {
    try {
      vacantRoomNoList.clear();

      List<RoomModel> allRooms = await roomController.fetchData();

      // Filter out vacant rooms (Vacancy > 0)
      vacantRooms = allRooms.where((room) => room.vacancy > 0).toList();

      if (vacantRooms.isNotEmpty) {
        // Create a Set to keep track of unique room numbers

        vacantRooms.sort((a, b) => a.roomNo.compareTo(b.roomNo));

        for (RoomModel room in vacantRooms) {
          String roomNumber = room.roomNo.toString();

          // Check if the room number hasn't been added before
          if (!vacantRoomNoList.contains(roomNumber)) {
            vacantRoomNoList.add(roomNumber);
          }
        }

        if (vacantRoomNoList.isNotEmpty) {
          selectedRoom = vacantRoomNoList[0].toString();
          selectedRoomId = vacantRooms[0].id!;
        }
      } else {
        // Handle case when all rooms are occupied
        selectedRoom = null; // or provide a default value
        selectedRoomId = null; // or provide a default value
      }

      notifyListeners();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

//-------------------------------------------------------------------------------Add Resident
  Future<void> addResident(BuildContext context) async {
    try {
      print("Starting addResident...");
      
      // Check Firebase connection
      final isConnected = await connectionController.isConnected();
      if (!isConnected) {
        print("No internet connection");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No internet connection")));
        return;
      }

      // Check if user is authenticated
      final user = auth.currentUser;
      if (user == null) {
        print("User not authenticated");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please login again")));
        return;
      }

      print("User authenticated: ${user.uid}");
      print("Form validation state: ${formKey.currentState?.validate()}");
      print("Selected room: $selectedRoom");
      print("Selected room ID: $selectedRoomId");
      print("Check-in date: $checkInDate");
      print("Check-out date: $checkOutDate");

      if (!formKey.currentState!.validate()) {
        print("Form validation failed");
        return;
      }

      if (selectedRoom == null || selectedRoom == "0") {
        print("No room selected");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a room")));
        return;
      }

      if (checkInDate == null || checkOutDate == null) {
        print("Dates not selected");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select check-in and check-out dates")));
        return;
      }

      String? uploadedImageUrl;
      if (selectedImage != null) {
        try {
          print("Uploading image...");
          uploadedImageUrl = await ownerRepository.uploadImage(
              'resident_images', XFile(selectedImage!.path));
          print("Image uploaded successfully: $uploadedImageUrl");
        } catch (e) {
          print("Error uploading image: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error uploading image: ${e.toString()}"),
          ));
          return;
        }
      }

      DateTime nextMonthDate = checkInDate!.add(const Duration(days: 30));
      print("Creating resident model...");
      final resident = ResidentModel(
          name: nameController.text,
          profilePic: uploadedImageUrl ?? "",
          roomNo: int.parse(selectedRoom!),
          roomId: selectedRoomId!,
          phone: phoneNoController.text,
          email: emailController.text,
          address: addressController.text,
          emargencyContact: emargencyContactController.text,
          purposOfStay: purposeController.text,
          checkIn: checkInDate!,
          checkOut: checkOutDate!,
          nextRentDate: nextMonthDate,
          isRentPaid: true);

      try {
        print("Adding resident to database...");
        // Initialize database structure first
        await residentsRepository.initializeDatabaseStructure();
        
        String documentId = await residentsRepository.addResidents(resident);
        print("Resident added successfully with ID: $documentId");
        
        if (isAddingaBookedResident && addingBooking != null) {
          print("Deleting booking...");
          await bookingsController.deleteBooking(
              context: context,
              bookingId: addingBooking!.id!,
              roomId: addingBooking!.roomId);
          isAddingaBookedResident = false;
          bookingsController.fetchBookingsData();
        }

        print("Updating room...");
        await updateRoom(newResidentId: documentId);
        print("Fetching updated residents list...");
        await fetchResidents();
        
        // Clear form fields
        nameController.clear();
        phoneNoController.clear();
        emailController.clear();
        addressController.clear();
        emargencyContactController.clear();
        purposeController.clear();
        checkInDateController.clear();
        checkOutDateController.clear();
        selectedImage = null;
        checkInDate = null;
        checkOutDate = null;
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resident added successfully")));
      } catch (e) {
        print("Error adding resident: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error adding resident: ${e.toString()}"),
        ));
      }
    } catch (e) {
      print("Error in addResident: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
      ));
    }
  }

//-------------------------------------------------------------------------------Edit Resident detaile

  Future<void> editResident(BuildContext context) async {
    try {
      final isConnected = await connectionController.isConnected();
      if (!isConnected) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Network error")));
      }

      if (selectedImage != null) {
        try {
          imageUrl = await ownerRepository.uploadImage(
              'resident_images', XFile(selectedImage!.path));
        } catch (e) {
          print("Error uploading image: ${e.toString()}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error uploading image: ${e.toString()}"),
          ));
          return;
        }
      }
      DateTime nextMonthDate = checkInDate!.add(const Duration(days: 30));

      final resident = ResidentModel(
          id: editingResidentId,
          name: nameController.text,
          profilePic: imageUrl ?? oldImage,
          roomNo: int.parse(selectedRoom!),
          roomId: selectedRoomId!,
          phone: phoneNoController.text,
          email: emailController.text,
          address: addressController.text,
          emargencyContact: emargencyContactController.text,
          purposOfStay: purposeController.text,
          checkIn: checkInDate!,
          checkOut: checkOutDate!,
          nextRentDate: nextMonthDate,
          isRentPaid: true);

      if (editingResidnt!.roomNo == int.parse(selectedRoom!)) {
        await residentsRepository.updateResident(resident);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Resident detailes Edited successfully")));
        Navigator.pop(context);
        refreshpage(context);
      } else {
        try {
          await residentsRepository.updateResident(resident);
          Navigator.pop(context);
          // await updateRoom(newResidentId: editingResidnt!.id.toString());

          // Fetch information about the old room
          final RoomModel? oldRoom = await roomController.fetchSingleRoom(
            roomId: editingResidnt!.roomId,
          );

          // Update the old room's data
          final int currentVacancy = oldRoom!.vacancy;
          final int updatedVacancy = currentVacancy + 1;
          final List<String> currentResidents = oldRoom.residents;
          final List<String> updatedResidents = List.from(currentResidents)
            ..remove(editingResidnt!.id.toString());

          // Update the old room document with new vacancy and residents list
          final Map<String, dynamic> oldRoomData = {
            "Vacancy": updatedVacancy,
            "Residents": updatedResidents,
          };
          await roomController.updateSingleField(
            json: oldRoomData,
            roomId: editingResidnt!.roomId,
          );

          // Fetch information about the new room
          final RoomModel? newRoom = await roomController.fetchSingleRoom(
            roomId: selectedRoomId!,
          );

          // Update the new room's data
          final int currentNewVacancy = newRoom!.vacancy;
          final int updatedNewVacancy = currentNewVacancy - 1;
          final List<String> currentNewResidents = newRoom.residents;
          final List<String> updatedNewResidents =
              List.from(currentNewResidents)
                ..add(editingResidnt!.id.toString());

          // Update the new room document with new vacancy and residents list
          final Map<String, dynamic> newRoomData = {
            "Vacancy": updatedNewVacancy,
            "Residents": updatedNewResidents,
          };
          await roomController.updateSingleField(
            json: newRoomData,
            roomId: selectedRoomId!,
          );
          Navigator.pop(context);
          refreshpage(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Resident details edited successfully")),
          );
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print("Error in editResident: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
      ));
    }
  }

//--------------------------------------------------------------------------------Add bookings to resident
  addBookingToResident(BookingsModel booking, BuildContext context) {
    nameController.text = booking.name;
    phoneNoController.text = booking.phoneNo;
    checkInDateController.text =
        DateFormat('dd/MM/yyyy').format(booking.checkIn);
    checkInDate = booking.checkIn;
    selectedRoom = booking.roomNO.toString();
    selectedRoomId = booking.roomId;
    isAddingaBookedResident = true;
    addingBooking = booking;
    notifyListeners();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => const ResidentsAddingPage(),
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
    );
  }

//------------------------------------------------------------------------------Delete Resident
  Future<void> deleteResident(
      {required BuildContext context, required ResidentModel resident}) async {
    try {
      final isConnected = await connectionController.isConnected();
      if (!isConnected) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Network error")));
      }
      await residentsRepository.deleteResident(resident.id!);

      final RoomModel? room =
          await roomController.fetchSingleRoom(roomId: resident.roomId);
      final currentVacancy = room!.vacancy;
      final int vacancy = currentVacancy + 1;
      final currentResidents = room.residents;
      currentResidents.remove(resident.id);
      notifyListeners();

      final Map<String, dynamic> json = {
        "Vacancy": vacancy,
        "Residents": currentResidents
      };
      await roomController.updateSingleField(
          json: json, roomId: resident.roomId);
      final OwnerModel? owner = await ownerRepository.fetchOwnerRecords();
      final currentHostelVacancy = owner!.noOfVacancy;
      final int hostelVacancy = currentHostelVacancy + 1;
      notifyListeners();
      final Map<String, dynamic> data = {'NoOfVacancy': hostelVacancy};
      await ownerRepository.accountSetup(data);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resident deleted Successfull")));
      Navigator.pop(context);
      refreshpage(context);
    } catch (e) {
      print(e);
    }
  }

//--------------------------------------------------------------------------------On edit
  onEdit(ResidentModel resident, BuildContext context) async {
    await fetchVacantRooms();
    isEditing = true;
    selectedRoom = resident.roomNo.toString();
    selectedRoomId = resident.roomId;
    selectedImage = null;
    oldImage = resident.profilePic;
    imageUrl = resident.profilePic;
    checkInDate = resident.checkIn;
    checkOutDate = resident.checkOut;
    nameController.text = resident.name;
    phoneNoController.text = resident.phone;
    emailController.text = resident.email;
    addressController.text = resident.address;
    emargencyContactController.text = resident.emargencyContact;
    purposeController.text = resident.purposOfStay;
    checkInDateController.text =
        DateFormat('dd/MM/yyyy').format(resident.checkIn);
    checkOutDateController.text =
        DateFormat('dd/MM/yyyy').format(resident.checkOut);
    editingRoomId = resident.roomId;
    oldRoomNo = resident.roomNo;
    editingResidentId = resident.id;
    editingResidnt = resident;
    if (!vacantRoomNoList.contains(resident.roomNo.toString())) {
      vacantRoomNoList.add(resident.roomNo.toString());
    }

    notifyListeners();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => const ResidentsAddingPage(),
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
    );
    notifyListeners();
  }
//------------------------------------------------------------------------------Edit rentpaid

  editRentPaid(
      {required String id,
      required DateTime currentRentDate,
      required BuildContext context}) async {
    try {
      DateTime nextDate = currentRentDate.add(const Duration(days: 30));
      Map<String, dynamic> json = {"NextRentDate": nextDate, "Rentpaid": true};
      await residentsRepository.updateSingleField(id, json);
      showSnackbar(context: context, content: "Rent Updated successfully");
      Navigator.pop(context);
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
      rethrow;
    }
  }

//------------------------------------------------------------------------------update room data
  Future<void> updateRoom({required String newResidentId}) async {
    try {
      final RoomModel? room =
          await roomController.fetchSingleRoom(roomId: selectedRoomId!);
      final currentVacancy = room!.vacancy;
      final int vacancy = currentVacancy - 1;
      final currentResidents = room.residents;
      currentResidents.add(newResidentId);
      notifyListeners();

      final Map<String, dynamic> json = {
        "Vacancy": vacancy,
        "Residents": currentResidents
      };
      await roomController.updateSingleField(
          json: json, roomId: selectedRoomId!);
    } catch (e) {
      print(e);
    }
  }

//------------------------------------------------------------------------------select Image
  Future<void> openImagePicker() async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (pickedImage != null) {
        selectedImage = File(pickedImage.path);
        notifyListeners();
      } else {
        if (kDebugMode) {
          print('Image not Selected');
        }
      }
    } catch (e) {
      print(e);
    }
  }

//------------------------------------------------------------------------------refresh page
  refreshpage(BuildContext context) {
    fetchResidents();
    fetchVacantRooms();
    notifyListeners();

    selectedImage = null;
    imageUrl = null;
    checkInDate = null;
    checkOutDate = null;
    selectedImage = null;
    oldImage = '';
    editingRoomId = null;
    editingResidentId = null;
    oldRoomNo = null;
    nameController.clear();
    phoneNoController.clear();
    emailController.clear();
    addressController.clear();
    emargencyContactController.clear();
    purposeController.clear();
    checkInDateController.clear();
    checkOutDateController.clear();
    isEditing = false;
    notifyListeners();
  }

  //----------------------------------------------------------------------------filter Rooms

  selectFilter(filter) async {
    isResidentsLoading = true;
    selctedFilter = filter;
    if (selctedFilter == "All Residents") {
      residents = allResidents;
    } else if (selctedFilter == "Rent Penting") {
      residents =
          allResidents.where((element) => element.isRentPaid == false).toList();
    }
    isResidentsLoading = false;
    notifyListeners();
  }

//------------------------------------------------------------------------------select room
  selectRoom(room) async {
    selectedRoom = room;
    selectedRoomId = findRoomByRoomNo(int.parse(selectedRoom!));
    notifyListeners();
  }

//------------------------------------------------------------------------------fetching RoomId
  String findRoomByRoomNo(int roomNumber) {
    // Find the first room in vacantRooms with the specified room number
    RoomModel? room = vacantRooms.firstWhere(
        (room) => room.roomNo == roomNumber,
        orElse: () => RoomModel.empty());
    return room.id!;
  }

//------------------------------------------------------------------------------Set checkIn date
  void setCheckInDate(DateTime date) {
    checkInDate = date;
    checkInDateController.text = DateFormat('dd/MM/yyy').format(date);
    notifyListeners();
  }

//------------------------------------------------------------------------------Set checkOut date
  void setCheckOutDate(DateTime date) {
    checkOutDate = date;
    checkOutDateController.text = DateFormat('dd/MM/yyy').format(date);
    notifyListeners();
  }

//-----------------------------------------------------------------------------Text field validation
  fieldValidation(value) {
    if (value == null || value.isEmpty) {
      return "this Field is required.";
    } else {
      return null;
    }
  }

  showSnackbar({required BuildContext context, required String content}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(content)));
  }
}
