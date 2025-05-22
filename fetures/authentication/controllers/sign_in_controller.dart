import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hostel_management_app/fetures/home/screen/home_screen.dart';
import 'package:hostel_management_app/fetures/profile/screens/account_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management_app/fetures/profile/models/owner_model.dart';

class SignInController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final DocumentSnapshot userData = await _firestore
            .collection("Owners")
            .doc(userCredential.user?.uid)
            .get();

        if (!userData.exists) {
          throw Exception('User data not found');
        }

        final owner = OwnerModel.fromSnapshot(userData);
        final bool isFirstTime = owner.isAccountSetupCompleted;

        if (!isFirstTime) {
          // Navigate to account setup if first time
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountSetupScreen(),
            ),
            (route) => false,
          );
        } else {
          // Navigate to home screen if already set up
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in with Google: ${e.toString()}'),
        ),
      );
    }
  }
} 