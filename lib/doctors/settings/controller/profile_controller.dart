import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  @override
  void onInit() {
    getData = getUserData();
    super.onInit();
  }

  var isLoading = false.obs;
  var currentUser = FirebaseAuth.instance.currentUser;
  var username = ''.obs;
  var email = ''.obs;
  var profileImageUrl = ''.obs; // Default to empty string
  Future? getData;

  final ImagePicker _picker = ImagePicker();

  Future<void> getUserData() async {
    isLoading(true);
    try {
      DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
          .instance
          .collection('doctors')
          .doc(currentUser!.uid)
          .get();
      var userData = user.data();
      if (userData != null) {
        username.value = userData['docName'] ?? "";
        email.value = currentUser!.email ?? "";
        profileImageUrl.value = userData['image'] ?? AppAssets.imgLogin;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile);
    }
  }

  Future<void> uploadImage(File image) async {
    isLoading(true);
    try {
      String fileName = 'profile_images/${currentUser!.uid}.jpg';
      UploadTask uploadTask =
      FirebaseStorage.instance.ref(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(currentUser!.uid)
          .update({'image': downloadUrl});

      profileImageUrl.value = downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}
