import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/terms_and_conditions_page.dart';
import 'package:hams/users/auth/view/role_selection_page.dart';
import 'package:hams/users/widgets/coustom_iconbutton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';
import '../controller/UserprofileController.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(Userprofilecontroller());
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
                    Expanded(
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: AppFontSize.size18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Obx(
                      () => controller.isLoading.value
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.whiteColor,
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: AppColors.whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(75),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primeryColor
                                              .withOpacity(0.2),
                                          AppColors.greenColor
                                              .withOpacity(0.2)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      image: DecorationImage(
                                        image: controller.profileImageUrl
                                            .value.isEmpty
                                            ? const AssetImage(
                                          'assets/images/img_login.jpg',
                                        )
                                            : NetworkImage(
                                          controller
                                              .profileImageUrl.value,
                                        ) as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showImagePickerBottomSheet(
                                            context, controller);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primeryColor,
                                              AppColors.greenColor
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.upload,
                                          color: AppColors.whiteColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              20.heightBox,
                              Text(
                                controller.username.value,
                                style: TextStyle(
                                  fontSize: AppFontSize.size16,
                                  color: AppColors.primeryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              10.heightBox,
                              Text(
                                controller.email.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              20.heightBox,
                              Divider(
                                color: AppColors.primeryColor
                                    .withOpacity(0.2),
                              ),
                              20.heightBox,
                              CoustomIconButton(
                                buttonColor: LinearGradient(
                                  colors: [
                                    AppColors.primeryColor,
                                    AppColors.greenColor
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () {
                                  Get.to(() => const TermsAndConditionsPage());
                                },
                                title: "Terms & Condition",
                                icon: Icon(
                                  Icons.edit_document,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                              20.heightBox,
                              CoustomIconButton(
                                buttonColor: LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.redAccent
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () async {
                                  await controller.signOut();
                                  Get.offAll(() => const RoleSelectionPage());
                                },
                                title: "Logout",
                                icon: Icon(
                                  Icons.logout,
                                  color: AppColors.whiteColor,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet(
      BuildContext context, Userprofilecontroller controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt, color: AppColors.primeryColor),
            title: Text(
              'Camera',
              style: TextStyle(color: AppColors.primeryColor),
            ),
            onTap: () async {
              Navigator.pop(context);
              await controller.pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo, color: AppColors.primeryColor),
            title: Text(
              'Gallery',
              style: TextStyle(color: AppColors.primeryColor),
            ),
            onTap: () async {
              Navigator.pop(context);
              await controller.pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}