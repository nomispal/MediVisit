import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hams/doctors/settings/controller/DoctorprofileController.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/view/login_page.dart';
import 'package:hams/users/widgets/coustom_iconbutton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(Doctorprofilecontroller());

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
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    child: Obx(
                          () => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  height: 150.h,
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: controller.profileImageUrl.value.isEmpty
                                          ? const AssetImage("AppAssets.imgLogin")
                                      as ImageProvider
                                          : NetworkImage(
                                          controller.profileImageUrl.value),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 50.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primeryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _showImagePickerBottomSheet(context, controller);
                                    },
                                    icon: const Icon(
                                      Icons.upload,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          15.heightBox,
                          Center(
                            child: Text(
                              controller.username.value,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          10.heightBox,
                          Center(
                            child: Text(
                              controller.email.value,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ),
                          20.heightBox,
                          const Divider(color: Colors.white),
                          10.heightBox,
                          CoustomIconButton(
                            color: Colors.black.withOpacity(.4),
                            onTap: () {},
                            title: "Terms & Conditions",
                            icon: const Icon(
                              Icons.edit_document,
                              color: Colors.white,
                            ),
                          ),
                          10.heightBox,
                          CoustomIconButton(
                            color: Colors.red,
                            onTap: () {
                              controller.signOut();
                              Get.offAll(() => const LoginView());
                            },
                            title: "Logout",
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                          ),
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

  void _showImagePickerBottomSheet(
      BuildContext context, Doctorprofilecontroller controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () async {
              Navigator.pop(context);
              await controller.pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Gallery'),
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