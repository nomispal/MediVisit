import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/controller/signup_controller.dart';
import 'package:hams/users/widgets/coustom_textfield.dart';
import 'package:hams/users/widgets/loading_indicator.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(SignupController());

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
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(16.0),
                color: AppColors.whiteColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.imgWelcome,
                        width: context.screenHeight * 0.2,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        AppString.signupNow,
                        style: TextStyle(
                          fontSize: AppFontSize.size16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primeryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: controller.formkey,
                        child: Column(
                          children: [
                            // Role Selection Dropdown
                            Obx(
                                  () => DropdownButtonFormField<String>(
                                value: controller.selectedRole.value,
                                decoration: InputDecoration(
                                  labelText: "Sign Up As",
                                  labelStyle: TextStyle(color: AppColors.primeryColor),
                                  filled: true,
                                  fillColor: AppColors.whiteColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: AppColors.primeryColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: AppColors.primeryColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: AppColors.primeryColor, width: 2),
                                  ),
                                ),
                                items: ["User", "Doctor"]
                                    .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  controller.setRole(value!);
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            CoustomTextField(
                              textcontroller: controller.nameController,
                              hint: AppString.fullName,
                              icon: const Icon(
                                Icons.person,
                                color: AppColors.primeryColor,
                              ),
                              validator: controller.validname,
                              textcolor: AppColors.secondaryTextColor,
                            ),
                            const SizedBox(height: 15),
                            CoustomTextField(
                              textcontroller: controller.emailController,
                              icon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primeryColor,
                              ),
                              hint: AppString.emailHint,
                              validator: controller.validateemail,
                              textcolor: AppColors.secondaryTextColor,
                            ),
                            const SizedBox(height: 15),
                            CoustomTextField(
                              textcontroller: controller.passwordController,
                              icon: const Icon(
                                Icons.key,
                                color: AppColors.primeryColor,
                              ),
                              hint: AppString.passwordHint,
                              validator: controller.validpass,
                              textcolor: AppColors.secondaryTextColor,
                            ),
                            // Conditionally show doctor-specific fields
                            Obx(
                                  () => controller.selectedRole.value == "Doctor"
                                  ? Column(
                                children: [
                                  const SizedBox(height: 15),
                                  CoustomTextField(
                                    textcontroller: controller.phoneController,
                                    icon: const Icon(
                                      Icons.phone,
                                      color: AppColors.primeryColor,
                                    ),
                                    hint: "Enter your phone number",
                                    validator: controller.validfield,
                                    textcolor: AppColors.secondaryTextColor,
                                  ),
                                  const SizedBox(height: 15),
                                  GestureDetector(
                                    onTap: () => controller.showDropdownMenu(context),
                                    child: CoustomTextField(
                                      textcontroller: controller.categoryController,
                                      hint: "Select Category",
                                      icon: const Icon( // Keep only one icon
                                        Icons.arrow_drop_down,
                                        color: AppColors.primeryColor,
                                      ),
                                      validator: controller.validfield,
                                      textcolor: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  CoustomTextField(
                                    textcontroller: controller.timeController,
                                    icon: const Icon(
                                      Icons.timer,
                                      color: AppColors.primeryColor,
                                    ),
                                    hint: "Write your service time",
                                    validator: controller.validfield,
                                    textcolor: AppColors.secondaryTextColor,
                                  ),
                                  const SizedBox(height: 15),
                                  CoustomTextField(
                                    textcontroller: controller.aboutController,
                                    icon: const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primeryColor,
                                    ),
                                    hint: "Write something about yourself",
                                    validator: controller.validfield,
                                    textcolor: AppColors.secondaryTextColor,
                                  ),
                                  const SizedBox(height: 15),
                                  CoustomTextField(
                                    textcontroller: controller.addressController,
                                    icon: const Icon(
                                      Icons.home_rounded,
                                      color: AppColors.primeryColor,
                                    ),
                                    hint: "Write your address",
                                    validator: controller.validfield,
                                    textcolor: AppColors.secondaryTextColor,
                                  ),
                                  const SizedBox(height: 15),
                                  CoustomTextField(
                                    textcontroller: controller.serviceController,
                                    icon: const Icon(
                                      Icons.type_specimen,
                                      color: AppColors.primeryColor,
                                    ),
                                    hint: "Write something about your service",
                                    validator: controller.validfield,
                                    textcolor: AppColors.secondaryTextColor,
                                  ),
                                ],
                              )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: context.screenWidth * 0.7,
                              height: 50,
                              child: Obx(
                                    () => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () async {
                                    await controller.signupUser(context);
                                    if (controller.userCredential != null) {
                                      if (controller.selectedRole.value == "User") {
                                        Get.offAllNamed('/home'); // Navigate to user home
                                      } else {
                                        Get.offAllNamed('/doctor_home'); // Navigate to doctor home
                                      }
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.primeryColor, AppColors.greenColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: controller.isLoading.value
                                          ? const LoadingIndicator()
                                          : Text(
                                        AppString.signup,
                                        style: const TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppString.alreadyHaveAccount,
                                  style: TextStyle(
                                    color: AppColors.secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    AppString.login,
                                    style: TextStyle(
                                      color: AppColors.primeryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}