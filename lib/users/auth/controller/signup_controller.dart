import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/doctors/home/view/home.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/home/view/home.dart';
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
  final String role;

  SignupController({required this.role});

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

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
          if (role == "User") {
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
              'image': "",
            });
          }
          isLoading(false);
          VxToast.show(
            context,
            msg: "Signup Successful",
            textColor: AppColors.whiteColor,
          );
          if (role == "User") {
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
    RegExp passwordRegExp = RegExp(r'^.{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'Password must contain at least 8 characters';
    }
    return null;
  }

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