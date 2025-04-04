import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/chat_view.dart';
import 'package:hams/users/review/view/review_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher.dart';

class Appointmentdetails extends StatelessWidget {
  final DocumentSnapshot doc;
  const Appointmentdetails({super.key, required this.doc});

  // Function to validate and format the phone number
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters (e.g., spaces, dashes)
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if the number already starts with a '+'
    if (!cleanedNumber.startsWith('+')) {
      // If not, prepend a default country code (e.g., +1 for the US)
      // You can adjust the country code based on your app's requirements
      cleanedNumber = '+1$cleanedNumber';
    }

    return cleanedNumber;
  }

  // Function to open the phone dialer
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    // Validate and format the phone number
    String formattedNumber = _formatPhoneNumber(phoneNumber);

    // Basic validation: ensure the number has at least 10 digits (excluding the country code)
    String digitsOnly = formattedNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      Get.snackbar(
        "Error",
        "Invalid phone number: $phoneNumber",
        backgroundColor: AppColors.primeryColor,
        colorText: AppColors.whiteColor,
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: formattedNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: Copy the phone number to the clipboard
        await Clipboard.setData(ClipboardData(text: formattedNumber));
        Get.snackbar(
          "Error",
          "Could not open phone dialer. Number copied to clipboard: $formattedNumber",
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor,
        );
      }
    } catch (e) {
      // Fallback: Copy the phone number to the clipboard
      await Clipboard.setData(ClipboardData(text: formattedNumber));
      Get.snackbar(
        "Error",
        "Failed to open phone dialer: $e. Number copied to clipboard: $formattedNumber",
        backgroundColor: AppColors.primeryColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the current user's ID
    bool canChat = doc['status'] == 'accept'; // Only allow chat if status is 'accept' (not 'complete')

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: "Appointment Details".text.make(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              width: context.screenWidth,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.bgDarkColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 75,
                    width: 75,
                    child: Image.asset(
                      AppAssets.imgLogin,
                      fit: BoxFit.cover,
                    ),
                  ),
                  15.widthBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Doctor name"
                          .text
                          .size(AppFontSize.size18)
                          .semiBold
                          .make(),
                      doc['appDocName']
                          .toString()
                          .text
                          .size(AppFontSize.size16)
                          .make(),
                      doc['appDocNum']
                          .toString()
                          .text
                          .size(AppFontSize.size12)
                          .make(),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.primeryColor,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Open the phone dialer with the doctor's phone number
                        _launchPhoneDialer(doc['appDocNum'].toString());
                      },
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            10.heightBox,
            Container(
              width: context.screenWidth,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.bgDarkColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.heightBox,
                  "Appointment day".text.semiBold.make(),
                  doc['appDay'].toString().text.make(),
                  10.heightBox,
                  "Appointment time".text.semiBold.make(),
                  doc['appTime'].toString().text.make(),
                  10.heightBox,
                  "patient's name".text.semiBold.make(),
                  doc['appName'].toString().text.make(),
                  10.heightBox,
                  "patient's phone".text.semiBold.make(),
                  doc['appMobile'].toString().text.make(),
                  30.heightBox,
                  "Status".text.semiBold.make(),
                  doc['status'].toString().text.make(),
                  40.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show "Give a Review" or "Thanks for Review" when status is "complete"
                      if (doc['status'] == "complete") ...[
                        doc['review'] == "false"
                            ? InkWell(
                          onTap: () {
                            Get.to(
                                  () => ReviewPage(
                                docId: doc['appWith'],
                                documetId: doc.id,
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                              color: AppColors.primeryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Give a Review",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        )
                            : InkWell(
                          onTap: () {
                            // Navigate to ChatView when "Thanks for Review" is tapped
                            Get.to(() => ChatView(
                              doctorId: doc['appWith'],
                              doctorName: doc['appDocName'],
                              userId: currentUserId,
                            ));
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                              color: AppColors.primeryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Thanks for Review",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Show "Chat with Doctor" only if status is "accept" (not "complete")
                      if (canChat) ...[
                        InkWell(
                          onTap: () {
                            Get.to(() => ChatView(
                              doctorId: doc['appWith'],
                              doctorName: doc['appDocName'],
                              userId: currentUserId,
                            ));
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primeryColor,
                                  AppColors.greenColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Chat with Doctor",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}