import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart'; // Updated to use consts.dart
import 'package:hams/general/list/home_icon_list.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../category_details/view/category_details.dart';

class CategoryScreenn extends StatefulWidget {
  const CategoryScreenn({super.key});

  @override
  _CategoryScreennState createState() => _CategoryScreennState();
}

class _CategoryScreennState extends State<CategoryScreenn> {
  Map<String, int> categoryDoctorCount = {};

  @override
  void initState() {
    super.initState();
    fetchDoctorCounts();
  }

  Future<void> fetchDoctorCounts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (String category in categoryTitle) {
      QuerySnapshot querySnapshot = await firestore
          .collection('doctors')
          .where('docCategory', isEqualTo: category)
          .get();

      if (mounted) {
        setState(() {
          categoryDoctorCount[category] = querySnapshot.size;
        });
      }
    }
  }

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
                    Expanded(
                      child: Text(
                        "Total Category",
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
              // Grid View
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: categoryImage.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      crossAxisCount: 2,
                      mainAxisExtent: 200,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      String category = categoryTitle[index];

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => CategoryDetailsView(
                            catName: category,
                          ));
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: AppColors.whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primeryColor.withOpacity(0.2),
                                          AppColors.greenColor.withOpacity(0.2)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Image.asset(
                                      categoryImage[index],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                category.text
                                    .size(AppFontSize.size16)
                                    .color(AppColors.primeryColor)
                                    .bold
                                    .make(),
                                const SizedBox(height: 8),
                                Text(
                                  "${categoryDoctorCount[category]?.toString() ?? ""} Specialists",
                                  style: TextStyle(
                                    color: AppColors.secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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