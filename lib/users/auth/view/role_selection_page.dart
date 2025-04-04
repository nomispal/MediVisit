import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/view/doctor_login_page.dart';
import 'package:hams/users/auth/view/doctor_signup_page.dart';
import 'package:hams/users/auth/view/user_login_page.dart';
import 'package:hams/users/auth/view/user_signup_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primeryColor.withOpacity(0.9),
              AppColors.greenColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Image/Icon
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      AppAssets.imgWelcome, // Replace with your welcome image
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ).animate().fadeIn(duration: 800.ms).scale(),

                  // Title
                  Text(
                    "Welcome to Hams",
                    style: TextStyle(
                      fontSize: AppFontSize.size20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.2),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    "Please select your role to continue",
                    style: TextStyle(
                      fontSize: AppFontSize.size16,
                      color: AppColors.whiteColor.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 50),

                  // User Button
                  _buildRoleButton(
                    context: context,
                    title: "I am a User",
                    icon: Icons.person,
                    onTap: () {
                      Get.to(() => const UserLoginView());
                    },
                  ).animate().fadeIn(duration: 1400.ms).slideY(begin: 0.3),

                  const SizedBox(height: 20),

                  // Doctor Button
                  _buildRoleButton(
                    context: context,
                    title: "I am a Doctor",
                    icon: Icons.medical_services,
                    onTap: () {
                      Get.to(() => const DoctorLoginView());
                    },
                  ).animate().fadeIn(duration: 1600.ms).slideY(begin: 0.3),

                  const SizedBox(height: 30),

                  // Optional: Tagline or Footer
                  Text(
                    "Your health, our priority.",
                    style: TextStyle(
                      fontSize: AppFontSize.size14,
                      color: AppColors.whiteColor.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(duration: 1800.ms).slideY(begin: 0.4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: context.screenWidth * 0.8,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.whiteColor.withOpacity(0.9),
            AppColors.whiteColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppColors.primeryColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSize.size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primeryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}