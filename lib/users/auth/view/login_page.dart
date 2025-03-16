import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/controller/login_controller.dart';
import 'package:hams/users/auth/reset_password/reset_password.dart';
import 'package:hams/users/auth/view/signup_page.dart';
import 'package:hams/users/widgets/coustom_textfield.dart';
import 'package:hams/users/widgets/loading_indicator.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(LoginController());

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
                        AppAssets.imgLogin,
                        width: context.screenHeight * 0.2,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        AppString.welcome,
                        style: TextStyle(
                          fontSize: AppFontSize.size18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primeryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppString.weAreExcuited,
                        style: TextStyle(
                          fontSize: AppFontSize.size18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryTextColor,
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
                                  labelText: "Login As",
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
                              validator: controller.validateemail,
                              textcontroller: controller.emailController,
                              icon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primeryColor,
                              ),
                              hint: AppString.emailHint,
                              textcolor: AppColors.secondaryTextColor,
                            ),
                            const SizedBox(height: 15),
                            CoustomTextField(
                              validator: controller.validpass,
                              textcontroller: controller.passwordController,
                              icon: const Icon(
                                Icons.key,
                                color: AppColors.primeryColor,
                              ),
                              hint: AppString.passwordHint,
                              textcolor: AppColors.secondaryTextColor,
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => const PasswordResetPage());
                                },
                                child: Text(
                                  "Forget Password?",
                                  style: TextStyle(
                                    color: AppColors.primeryColor,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
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
                                    controller.loginUser(context);
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
                                        AppString.login,
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
                                  AppString.dontHaveAccount,
                                  style: TextStyle(
                                    color: AppColors.secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => const SignupView());
                                  },
                                  child: Text(
                                    AppString.signup,
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