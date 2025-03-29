import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/home/view/home.dart';
import '../../../doctors/home/view/home.dart';

class LoginController extends GetxController {
  UserCredential? userCredential;
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final String role; // Role is now passed via constructor

  LoginController({required this.role});

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Login method for both user and doctor
  loginUser(context) async {
    if (formkey.currentState!.validate()) {
      try {
        isLoading(true);
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (userCredential != null) {
          String currentUserId = FirebaseAuth.instance.currentUser!.uid;
          String collection = role == "User" ? 'users' : 'doctors';
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(collection)
              .doc(currentUserId)
              .get();

          if (!userDoc.exists) {
            isLoading(false);
            Get.snackbar(
              "Login failed",
              "No ${role.toLowerCase()} account found.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.primeryColor,
              colorText: AppColors.whiteColor,
            );
            return;
          }

          if (userDoc['role'] == role.toLowerCase()) {
            isLoading(false);
            Get.snackbar(
              "Success",
              "Login Successful",
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.primeryColor,
              colorText: AppColors.whiteColor,
            );
            if (role == "User") {
              Get.offAll(const Home());
            } else {
              Get.offAll(const DoctorHome());
            }
          } else {
            isLoading(false);
            Get.snackbar(
              "Login failed",
              "You are not authorized as a ${role.toLowerCase()}.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.primeryColor,
              colorText: AppColors.whiteColor,
            );
          }
        }
      } catch (e) {
        isLoading(false);
        Get.snackbar(
          "Login failed",
          "Wrong email or password",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor,
        );
      }
    }
  }

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

  String? validpass(value) {
    if (value!.isEmpty) {
      return 'Please enter a password';
    }
    RegExp passRefExp = RegExp(r'^.{8,}$');
    if (!passRefExp.hasMatch(value)) {
      return 'Password must contain at least 8 characters';
    }
    return null;
  }
}