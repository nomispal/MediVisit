import 'package:flutter/material.dart';
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
    final formKey = GlobalKey<FormState>(); // Define formKey for search validation

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
              // Search Section (White AppBar-like section at the top)
              Container(
                padding: const EdgeInsets.all(8),
                color: AppColors.whiteColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppString.welcome.text
                            .size(AppFontSize.size16)
                            .fontWeight(FontWeight.bold)
                            .color(AppColors.primeryColor)
                            .make(),
                        5.widthBox,
                        Expanded(
                          child: Obx(
                                () => Text(
                              "${controller.userName}",
                              style: TextStyle(
                                fontSize: AppFontSize.size16,
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
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.primeryColor,
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.primeryColor,
                                    width: 2.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                hintText: "Search doctor",
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
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: AppColors.primeryColor,
                              borderRadius: BorderRadius.circular(5),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                            "Popular Category"
                                .text
                                .color(AppColors.primeryColor)
                                .size(AppFontSize.size16)
                                .fontWeight(FontWeight.bold)
                                .make(),
                            10.heightBox,
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: iconListTitle.length, // Use actual length
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      print("Tapped category: ${iconListTitle[index]}"); // Debug log
                                      Get.to(() => CategoryDetailsView(catName: iconListTitle[index]));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.greenColor,
                                        borderRadius: BorderRadius.circular(15),
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
                                              .make(),
                                        ],
                                      ),
                                    ),
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
                                .color(AppColors.primeryColor)
                                .size(AppFontSize.size16)
                                .fontWeight(FontWeight.bold)
                                .make(),
                            10.heightBox,
                            FutureBuilder<QuerySnapshot>(
                              future: controller.getDoctorList(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox(
                                    height: 195,
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
                                  // Debug: Log all doctor categories
                                  for (var doc in data!) {
                                    print("Doctor Category: ${doc['docCategory']}");
                                  }
                                  return SizedBox(
                                    height: 195,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        String imageUrl = data[index].data().toString().contains('image')
                                            ? data[index]["image"]
                                            : "";
                                        return GestureDetector(
                                          onTap: () {
                                            Get.to(() => DoctorProfile(doc: data[index]));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.bgDarkColor,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.only(bottom: 5),
                                            margin: const EdgeInsets.only(right: 8),
                                            height: 180,
                                            width: 130,
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: imageUrl.isEmpty
                                                      ? Image.asset(
                                                    AppAssets.imgLogin,
                                                    height: 130,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                      : Image.network(
                                                    imageUrl,
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
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
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
                                          ),
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
                      80.heightBox, // Extra padding for bottom navigation
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