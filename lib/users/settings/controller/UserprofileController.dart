import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // For Base64 encoding/decoding

class Userprofilecontroller extends GetxController {
  var isLoading = false.obs;
  var username = "".obs;
  var email = "".obs;
  var profileImageUrl = "".obs; // Will now store the Base64 string

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
          profileImageUrl.value = userDoc['image'] ?? ''; // Base64 string or empty
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
      // Pick the image with compression
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxHeight: 512, // Resize to reduce file size
        maxWidth: 512,
        imageQuality: 85, // Compress the image (0-100)
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await uploadImage(imageFile);
      } else {
        Get.snackbar("Info", "No image selected");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      isLoading(true);
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Get.snackbar("Error", "User not authenticated. Please log in.");
        return;
      }

      // Check file size before converting to Base64
      int fileSizeInBytes = await imageFile.length();
      const int maxSizeInBytes = 700 * 1024; // 700 KB to be safe (Base64 increases size by ~33%)
      if (fileSizeInBytes > maxSizeInBytes) {
        Get.snackbar("Error", "Image is too large. Maximum size is 700 KB.");
        return;
      }

      // Convert the image to Base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Check the size of the Base64 string (Firestore document size limit is 1 MB)
      int base64SizeInBytes = base64Image.length;
      if (base64SizeInBytes > 1 * 1024 * 1024) {
        Get.snackbar("Error", "Encoded image is too large for Firestore. Please use a smaller image.");
        return;
      }

      // Store the Base64 string in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'image': base64Image,
      });

      // Update the local state with the Base64 string
      profileImageUrl.value = base64Image;
      Get.snackbar("Success", "Profile image updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image to Firestore: $e");
    } finally {
      isLoading(false);
    }
  }

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