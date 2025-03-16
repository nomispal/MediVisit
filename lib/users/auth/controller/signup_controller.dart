import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/doctors/home/view/home.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/home/view/home.dart'; // User home screen
import 'dart:developer';

class SignupController extends GetxController {
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var categoryController = TextEditingController();
  var timeController = TextEditingController();
  var aboutController = TextEditingController();
  var addressController = TextEditingController();
  var serviceController = TextEditingController();
  UserCredential? userCredential;
  var isLoading = false.obs;
  var selectedRole = "User".obs; // Role selection: "User" or "Doctor"

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Toggle role between User and Doctor
  void setRole(String role) {
    selectedRole.value = role;
  }

  // Show dropdown for doctor category selection
  void showDropdownMenu(BuildContext context) {
    final List<PopupMenuEntry<String>> items = [
      const PopupMenuItem(value: 'Body', child: Text('Body')),
      const PopupMenuItem(value: 'Ear', child: Text('Ear')),
      const PopupMenuItem(value: 'Liver', child: Text('Liver')),
      const PopupMenuItem(value: 'Lungs', child: Text('Lungs')),
      const PopupMenuItem(value: 'Heart', child: Text('Heart')),
      const PopupMenuItem(value: 'Kidny', child: Text('Kidny')),
      const PopupMenuItem(value: 'Eye', child: Text('Eye')),
      const PopupMenuItem(value: 'Stomac', child: Text('Stomac')),
      const PopupMenuItem(value: 'Tooth', child: Text('Tooth')),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          Offset.zero,
          Offset.zero,
        ),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: items,
    ).then((value) {
      if (value != null) {
        categoryController.text = value;
      }
    });
  }

  signupUser(context) async {
    if (formkey.currentState!.validate()) {
      try {
        isLoading(true);
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (userCredential != null) {
          String uid = userCredential!.user!.uid;
          if (selectedRole.value == "User") {
            // Store user data
            var store = FirebaseFirestore.instance.collection('users').doc(uid);
            await store.set({
              'uid': uid,
              'fullname': nameController.text,
              'password': passwordController.text,
              'email': emailController.text,
              'deviceToken': '',
              'role': 'user',
            });
          } else {
            // Store doctor data
            var store = FirebaseFirestore.instance.collection('doctors').doc(uid);
            await store.set({
              'docId': uid,
              'docName': nameController.text,
              'docPassword': passwordController.text,
              'docEmail': emailController.text,
              'docAbout': aboutController.text,
              'docAddress': addressController.text,
              'docCategory': categoryController.text,
              'docPhone': phoneController.text,
              'docRating': '0',
              'docService': serviceController.text,
              'docTimeing': timeController.text,
              'deviceToken': "",
              'status': "approved",
              'role': "doctor",
              'image': "", // Add default empty image field
            });
          }
          isLoading(false);
          VxToast.show(
            context,
            msg: "Signup Successful",
            textColor: AppColors.whiteColor,
          );
          if (selectedRole.value == "User") {
            Get.offAll(const Home());
          } else {
            Get.offAll(const DoctorHome());
          }
        }
      } catch (e) {
        isLoading(false);
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            VxToast.show(
              context,
              msg: "Already have an account",
              textColor: AppColors.whiteColor,
            );
          } else {
            VxToast.show(
              context,
              msg: "No internet connection",
              textColor: AppColors.whiteColor,
            );
          }
        } else {
          VxToast.show(
            context,
            msg: "Try after some time",
            textColor: AppColors.whiteColor,
          );
        }
        log("$e");
      }
    }
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Validate email
  String? validateemail(value) {
    if (value!.isEmpty) {
      return 'Please enter an email';
    }
    RegExp emailRefExp = RegExp(r'^[\w\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRefExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate password (using stricter rules for both user and doctor)
  String? validpass(value) {
    if (value!.isEmpty) {
      return 'Please enter a password';
    }
    // Check for at least one capital letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one capital letter';
    }
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#\$&*~]'))) {
      return 'Password must contain at least one special character (!@#\$&*~)';
    }
    // Check for overall pattern
    RegExp passwordRegExp =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'Your Password Must Contain At Least 8 Characters';
    }
    return null;
  }

  // Validate name
  String? validname(value) {
    if (value!.isEmpty) {
      return 'Please enter a name';
    }
    RegExp nameRegExp = RegExp(r'^.{5,}$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Please enter a valid name (at least 5 characters)';
    }
    return null;
  }

  // Validate other fields (phone, about, address, service, timing, etc.)
  String? validfield(value) {
    if (value!.isEmpty) {
      return 'Please fill this field';
    }
    RegExp fieldRegExp = RegExp(r'^.{2,}$');
    if (!fieldRegExp.hasMatch(value)) {
      return 'Please enter at least 2 characters';
    }
    return null;
  }
}