import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Doctorprofilecontroller extends GetxController {
  var isLoading = false.obs;
  var username = "".obs;
  var email = "".obs;
  var profileImageUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    try {
      isLoading(true);
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot doctorDoc =
        await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
        if (doctorDoc.exists) {
          username.value = doctorDoc['docName'] ?? '';
          email.value = doctorDoc['docEmail'] ?? '';
          profileImageUrl.value = doctorDoc['image'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch doctor data: $e");
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
      FirebaseStorage.instance.ref().child('doctor_images/$uid.jpg');
      await storageRef.putFile(imageFile);
      String downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .update({'image': downloadUrl});
      profileImageUrl.value = downloadUrl;
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("Doctor signed out successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to sign out: $e");
      print("Sign out error: $e");
    }
  }
}