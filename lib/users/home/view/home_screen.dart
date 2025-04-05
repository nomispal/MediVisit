import 'dart:convert'; // For Base64 decoding
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/general/list/home_icon_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../category_details/view/category_details.dart';
import '../../doctor_profile/view/doctor_view.dart';
import '../../search/controller/search_controller.dart';
import '../../search/view/search_view.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    var searchController = Get.put(DocSearchController());
    final formKey = GlobalKey<FormState>();

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
          child: Column(
            children: [
              // Search Section
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.whiteColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppString.welcome.text
                            .size(AppFontSize.size20)
                            .fontWeight(FontWeight.bold)
                            .color(AppColors.primeryColor)
                            .make(),
                        5.widthBox,
                        Expanded(
                          child: Obx(
                                () => Text(
                              "${controller.userName}",
                              style: TextStyle(
                                fontSize: AppFontSize.size18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primeryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.heightBox,
                    Form(
                      key: formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: searchController.searchQueryController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15.0,
                                ),
                                filled: true,
                                fillColor: AppColors.whiteColor,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.primeryColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                    color: AppColors.primeryColor.withOpacity(0.5),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                    color: AppColors.primeryColor,
                                    width: 2.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                hintText: "Search for a doctor...",
                                hintStyle: TextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              style: TextStyle(color: AppColors.primeryColor),
                              validator: (value) =>
                              value!.isEmpty ? 'This field cannot be empty' : null,
                            ),
                          ),
                          10.widthBox,
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primeryColor, AppColors.greenColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (searchController.searchQueryController.text.isNotEmpty) {
                                    Get.to(() => SearchView(
                                      searchQuery: searchController.searchQueryController.text,
                                    ));
                                  } else {
                                    Get.showSnackbar(
                                      const GetSnackBar(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        title: "Empty input",
                                        message: "Please input something first",
                                        animationDuration: Duration(seconds: 1),
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.grey,
                                        dismissDirection: DismissDirection.horizontal,
                                        duration: Duration(seconds: 2),
                                        borderRadius: 10,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.search,
                                color: AppColors.whiteColor,
                                size: 30,
                              ),
                            ),
                          ).animate().scale(duration: 300.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Popular Category Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Popular Categories"
                                .text
                                .color(AppColors.whiteColor)
                                .size(AppFontSize.size18)
                                .fontWeight(FontWeight.bold)
                                .make()
                                .animate()
                                .fadeIn(duration: 1000.ms),
                            10.heightBox,
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: iconListTitle.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      print("Tapped category: ${iconListTitle[index]}");
                                      Get.to(() => CategoryDetailsView(catName: iconListTitle[index]));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.greenColor,
                                            AppColors.primeryColor,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            iconList[index],
                                            width: 50,
                                            fit: BoxFit.contain,
                                          ),
                                          5.heightBox,
                                          iconListTitle[index]
                                              .text
                                              .color(AppColors.whiteColor)
                                              .size(AppFontSize.size14)
                                              .fontWeight(FontWeight.w500)
                                              .make(),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 1200.ms).slideX(begin: 0.2),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      15.heightBox,
                      // Popular Doctors Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Popular Doctors"
                                .text
                                .color(AppColors.whiteColor)
                                .size(AppFontSize.size18)
                                .fontWeight(FontWeight.bold)
                                .make()
                                .animate()
                                .fadeIn(duration: 1400.ms),
                            10.heightBox,
                            FutureBuilder<QuerySnapshot>(
                              future: controller.getDoctorList(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 5,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            margin: const EdgeInsets.only(right: 8),
                                            height: 180,
                                            width: 130,
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: Container(
                                                    height: 130,
                                                    width: double.infinity,
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  height: 16,
                                                  width: 100,
                                                  color: Colors.grey[300],
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  height: 12,
                                                  width: 60,
                                                  color: Colors.grey[300],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  var data = snapshot.data?.docs;
                                  for (var doc in data!) {
                                    print("Doctor Category: ${doc['docCategory']}");
                                  }
                                  return SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        String imageBase64 = data[index].data().toString().contains('image')
                                            ? data[index]["image"]
                                            : "";
                                        return GestureDetector(
                                          onTap: () {
                                            Get.to(() => DoctorProfile(doc: data[index]));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.whiteColor,
                                              borderRadius: BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.only(bottom: 5),
                                            margin: const EdgeInsets.only(right: 8),
                                            height: 180,
                                            width: 130,
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(15),
                                                    topRight: Radius.circular(15),
                                                  ),
                                                  child: imageBase64.isEmpty
                                                      ? Image.asset(
                                                    AppAssets.imgLogin,
                                                    height: 130,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                      : Image.memory(
                                                    base64Decode(imageBase64),
                                                    height: 130,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Image.asset(
                                                        AppAssets.imgLogin,
                                                        height: 130,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: Text(
                                                    data[index]['docName'] ?? 'Unknown',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: AppFontSize.size14,
                                                      color: AppColors.primeryColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                (data[index]['docCategory']?.toString() ?? 'N/A')
                                                    .text
                                                    .size(AppFontSize.size12)
                                                    .color(AppColors.secondaryTextColor)
                                                    .make(),
                                              ],
                                            ),
                                          ).animate().fadeIn(duration: 1600.ms).slideX(begin: 0.2),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      80.heightBox,
                    ],
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