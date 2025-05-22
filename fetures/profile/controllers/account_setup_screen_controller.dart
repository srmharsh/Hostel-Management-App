// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hostel_management_app/fetures/profile/controllers/user_repository.dart';
import 'package:hostel_management_app/fetures/home/screen/home_screen.dart';
import 'package:image_picker/image_picker.dart';

class AccountSetUpScreenController with ChangeNotifier {
  List<int> noOfRooms = [];
  final hostelNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final roomNumberController = TextEditingController();
  String? imageUrl;
  File? selectedImage;
  GlobalKey<FormState> accountSetupFormKey = GlobalKey<FormState>();

  final UserRepository controller = UserRepository();

  Future<void> updateOwnerRecords(BuildContext context, String pro) async {
    if (selectedImage != null) {
      try {
        imageUrl = await controller.uploadImage(
            'Owners/Images/Profile', XFile(selectedImage!.path));
      } catch (e) {
        print(e);
      }
    }
    final Map<String, dynamic> json = {
      'hostelName': hostelNameController.text,
      'address': addressController.text,
      'mobileNumber': phoneNumberController.text,
      'profilePicture': imageUrl ?? pro,
      'noOfRooms': int.tryParse(roomNumberController.text) ?? 0,
      'isAccountSetupCompleted': true
    };

    try {
      await controller.accountSetup(json);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false);
      hostelNameController.clear();
      addressController.clear();
      phoneNumberController.clear();
      imageUrl = '';
      roomNumberController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
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
        print('Image not Selected');
      }
    } catch (e) {
      print(e);
    }
  }
  //------------------------------------------------------------------------------ form valitator

  nameValidation(value) {
    if (value == null || value.isEmpty) {
      return "This field is required.";
    } else {
      return null;
    }
  }

  updateData(BuildContext context, String pro) async {
    try {
      // Prepare the data to update
      final Map<String, dynamic> json = {
        'hostelName': hostelNameController.text,
        'address': addressController.text,
        'mobileNumber': phoneNumberController.text,
        'profilePicture': imageUrl ?? pro,
        'noOfRooms': int.tryParse(roomNumberController.text) ?? 0,
        'isAccountSetupCompleted': true
      };

      // Update Firestore using your repository
      await controller.accountSetup(json);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      // Clear controllers
      hostelNameController.clear();
      addressController.clear();
      phoneNumberController.clear();
      imageUrl = '';
      roomNumberController.clear();

      // Optionally, navigate away
      Navigator.pop(context);

      // Optionally, notify listeners if you want to update the UI
      notifyListeners();
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }
}
