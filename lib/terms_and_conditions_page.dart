import 'package:flutter/material.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:get/get.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: "Terms & Conditions"
                          .text
                          .size(AppFontSize.size18)
                          .color(AppColors.whiteColor)
                          .bold
                          .makeCentered(),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: AppColors.whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Terms and Conditions"
                              .text
                              .size(AppFontSize.size16)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          20.heightBox,
                          "Last Updated: March 31, 2025"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.secondaryTextColor)
                              .make(),
                          20.heightBox,
                          "Welcome to Hams! These Terms and Conditions govern your use of our app and services. By using Hams, you agree to comply with these terms. If you do not agree, please do not use the app."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "1. Use of the App"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "You must be at least 18 years old to use this app. You agree to use the app only for lawful purposes and in a way that does not infringe the rights of others."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "2. User Accounts"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "You are responsible for maintaining the confidentiality of your account and password. You agree to notify us immediately of any unauthorized use of your account."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "3. Doctor-Patient Communication"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "The app facilitates communication between doctors and patients. However, Hams is not responsible for the accuracy of medical advice provided by doctors through the app."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "4. Privacy"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your personal information."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "5. Limitation of Liability"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "Hams is not liable for any damages arising from your use of the app, including but not limited to, indirect, incidental, or consequential damages."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "6. Changes to These Terms"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "We may update these Terms and Conditions from time to time. We will notify you of changes by posting the updated terms in the app. Your continued use of the app after such changes constitutes your acceptance of the new terms."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                          20.heightBox,
                          "7. Contact Us"
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.primeryColor)
                              .bold
                              .make(),
                          10.heightBox,
                          "If you have any questions about these Terms and Conditions, please contact us at support@Hams.com."
                              .text
                              .size(AppFontSize.size14)
                              .color(AppColors.textcolor)
                              .make(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}