import 'dart:convert'; // For Base64 decoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/all%20reviews/all_reviews.dart';
import 'package:hams/users/chat_view.dart';
import 'package:hams/users/doctor_profile/widgets/review_card.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../book_appointment/view/appointment_view.dart';
import '../../widgets/coustom_button.dart';

class DoctorProfile extends StatelessWidget {
  final DocumentSnapshot doc;
  const DoctorProfile({super.key, required this.doc});

  // Check if the user has an appointment with this doctor
  Future<bool> hasAppointment(String userId) async {
    var appointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('appBy', isEqualTo: userId)
        .where('appWith', isEqualTo: doc['docId'])
        .get();
    return appointments.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Assuming you have the current user's ID (you might get this from auth)
    String currentUserId = "user123"; // Replace with actual user ID from auth

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primeryColor, AppColors.greenColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar (unchanged)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: "Doctor Details"
                          .text
                          .size(AppFontSize.size18)
                          .color(AppColors.whiteColor)
                          .bold
                          .makeCentered(),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: AppColors.whiteColor,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: 75,
                                  width: 75,
                                  child: doc.data().toString().contains('image') && doc['image'] != ''
                                      ? Image.memory(
                                    base64Decode(doc['image']),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        AppAssets.imgLogin,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                      : Image.asset(
                                    AppAssets.imgLogin,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                15.widthBox,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            doc['docName'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: AppFontSize.size16,
                                              color: AppColors.primeryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Category: ${doc['docCategory'] ?? 'N/A'}",
                                        style: TextStyle(
                                          fontSize: AppFontSize.size14,
                                          color: AppColors.secondaryTextColor,
                                        ),
                                      ),
                                      8.heightBox,
                                      RatingBarIndicator(
                                        rating: double.parse(doc['docRating']?.toString() ?? '0'),
                                        itemBuilder: (context, index) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        direction: Axis.horizontal,
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(
                                          () => BookAppointmentView(
                                        docId: doc['docId'],
                                        docName: doc['docName'],
                                        docNum: doc['docPhone'],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.primeryColor, AppColors.greenColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Center(
                                        child: Text(
                                          "Book an Appointment",
                                          style: TextStyle(color: AppColors.whiteColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        10.heightBox,
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: AppColors.whiteColor,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "About"
                                    .text
                                    .semiBold
                                    .size(AppFontSize.size18)
                                    .color(AppColors.primeryColor)
                                    .make(),
                                5.heightBox,
                                (doc['docAbout']?.toString() ?? 'N/A')
                                    .text
                                    .size(AppFontSize.size14)
                                    .color(AppColors.textcolor)
                                    .make(),
                                10.heightBox,
                                "Address"
                                    .text
                                    .semiBold
                                    .size(AppFontSize.size18)
                                    .color(AppColors.primeryColor)
                                    .make(),
                                5.heightBox,
                                (doc['docAddress']?.toString() ?? 'N/A')
                                    .text
                                    .size(AppFontSize.size14)
                                    .color(AppColors.textcolor)
                                    .make(),
                                10.heightBox,
                                "Working Time"
                                    .text
                                    .semiBold
                                    .size(AppFontSize.size18)
                                    .color(AppColors.primeryColor)
                                    .make(),
                                5.heightBox,
                                (doc['docTimeing']?.toString() ?? 'N/A')
                                    .text
                                    .size(AppFontSize.size14)
                                    .color(AppColors.textcolor)
                                    .make(),
                                10.heightBox,
                                "Services"
                                    .text
                                    .semiBold
                                    .size(AppFontSize.size18)
                                    .color(AppColors.primeryColor)
                                    .make(),
                                5.heightBox,
                                (doc['docService']?.toString() ?? 'N/A')
                                    .text
                                    .size(AppFontSize.size14)
                                    .color(AppColors.textcolor)
                                    .make(),
                                25.heightBox,
                                ListTile(
                                  title: "Contact Details"
                                      .text
                                      .semiBold
                                      .size(AppFontSize.size16)
                                      .color(AppColors.primeryColor)
                                      .make(),
                                  subtitle: "First book an Appointment for contact details"
                                      .text
                                      .size(AppFontSize.size12)
                                      .color(AppColors.secondaryTextColor)
                                      .make(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _buildReviewSection(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool>(
              future: hasAppointment(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return CoustomButton(
                    onTap: () {
                      Get.to(() => ChatView(
                        doctorId: doc['docId'],
                        doctorName: doc['docName'],
                        userId: currentUserId,
                      ));
                    },
                    title: "Chat with Doctor",
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            10.heightBox,
            CoustomButton(
              onTap: () {
                Get.to(
                      () => AllReviewsPage(
                    doctorId: doc.id,
                  ),
                );
              },
              title: "See All Reviews",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(doc.id)
          .collection('reviews')
          .orderBy('rating', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return "No reviews available".text.color(AppColors.secondaryTextColor).makeCentered();
        }

        var reviews = snapshot.data!.docs;

        int reviewCount = reviews.length > 5 ? 5 : reviews.length;

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviewCount,
            itemBuilder: (context, index) {
              var review = reviews[index];
              return buildReviewCard(review);
            },
          ),
        );
      },
    );
  }
}