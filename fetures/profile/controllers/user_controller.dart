// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hostel_management_app/fetures/authentication/controllers/authentication_repository.dart';
import 'package:hostel_management_app/commens/functions/loading_controller.dart';
import 'package:hostel_management_app/fetures/profile/controllers/user_repository.dart';
import 'package:hostel_management_app/fetures/profile/models/owner_model.dart';
import 'package:hostel_management_app/fetures/authentication/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class UserController with ChangeNotifier {
  OwnerModel? user;
  final UserRepository controller = UserRepository();
  final loadingController = FullScreenLoader();
  bool isProfileUploading = false;

  //----------------------------------------------------------------------------Fetch user data

  fetchData() async {
    try {
      final currentUser = await controller.fetchOwnerRecords();
      user = currentUser;
      notifyListeners();
    } catch (e) {
      print('Error fetching user data: $e');
      user = OwnerModel.empty();
      notifyListeners();
    }
  }

  // Initialize user data
  Future<void> initialize() async {
    await fetchData();
  }

  final nameController = TextEditingController();
  final hostelNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNoController = TextEditingController();
  final addressController = TextEditingController();
  final roonNoController = TextEditingController();
  GlobalKey<FormState> profileUpdateFormKey = GlobalKey<FormState>();

  fillForm() {
    nameController.text = user!.ownerName;
    hostelNameController.text = user!.hostelName;
    emailController.text = user!.emailAddress;
    phoneNoController.text = user!.mobileNumber;
    addressController.text = user!.address;
    roonNoController.text = user!.noOfRooms.toString();
  }
  //----------------------------------------------------------------------------Update user data

  updateData(context, pro) async {
    try {
      final updatedUser = OwnerModel(
        id: user!.id,
        createdAt: user!.createdAt,
        updatedAt: DateTime.now(),
        ownerName: nameController.text,
        hostelName: hostelNameController.text,
        emailAddress: emailController.text,
        mobileNumber: phoneNoController.text,
        address: addressController.text,
        profilePicture: pro,
        noOfRooms: int.tryParse(roonNoController.text) ?? 0,
        noOfBeds: user!.noOfBeds,
        noOfVacancy: user!.noOfVacancy,
        isAccountSetupCompleted: user!.isAccountSetupCompleted,
      );
      await controller.updateOwnerRecords(updatedUser);
      await fetchData();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully")));
    } catch (e) {
      print(e.toString());
    }
  }
  //----------------------------------------------------------------------------Delte user

  deleteUserAccount(context) async {
    try {
      final auth = AuthenticationRepository();
      await auth.deleteAccount();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Deleted Successfully")));

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false);
    } catch (e) {
      print(e.toString());
    }
  }
  //----------------------------------------------------------------------------Upload profile pick

  uploadUserProfilePicture(context) async {
    try {
      isProfileUploading = true;
      notifyListeners();
      
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
          
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No image selected")));
        return;
      }

      final imageUrl = await controller.uploadImage('profile_pictures', image);
      
      if (imageUrl != null) {
        // Ensure the image URL ends with .jpg
        final imageUrlWithJpg = imageUrl.endsWith('.jpg') ? imageUrl : '$imageUrl.jpg';
        Map<String, dynamic> json = {"profilePicture": imageUrlWithJpg};
        await controller.updateProfile(json);
        
        await fetchData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Profile picture updated successfully")));
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error uploading profile picture: ${e.toString()}")));
    } finally {
      isProfileUploading = false;
      notifyListeners();
    }
  }

  fieldValidation(value) {
    if (value == null || value.isEmpty) {
      return "Name is required.";
    } else {
      return null;
    }
  }
}
