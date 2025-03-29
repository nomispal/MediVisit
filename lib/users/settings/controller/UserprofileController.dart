import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Userprofilecontroller extends GetxController {
  var isLoading = false.obs;
  var username = "".obs;
  var email = "".obs;
  var profileImageUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading(true);
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          username.value = userDoc['fullname'] ?? '';
          email.value = userDoc['email'] ?? '';
          profileImageUrl.value = userDoc['image'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user data: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await uploadImage(imageFile);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      isLoading(true);
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      Reference storageRef =
      FirebaseStorage.instance.ref().child('user_images/$uid.jpg');
      await storageRef.putFile(imageFile);
      String downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'image': downloadUrl});
      profileImageUrl.value = downloadUrl;
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image: $e");
    } finally {
      isLoading(false);
    }
  }

  // Add signOut method
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("User signed out successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to sign out: $e");
      print("Sign out error: $e");
    }
  }
}