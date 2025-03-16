import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../doctor_profile/view/doctor_view.dart';

class SearchView extends StatelessWidget {
  final String searchQuery;
  const SearchView({super.key, required this.searchQuery});

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
                      child: "Search Results"
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
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('doctors').get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.whiteColor,
                        ),
                      );
                    } else {
                      var filteredDocs = snapshot.data!.docs.where((doc) {
                        String docName = doc['docName'].toString().toLowerCase();
                        return docName.contains(searchQuery.toLowerCase());
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: "No doctor found, try another name."
                              .text
                              .size(18)
                              .color(AppColors.whiteColor.withOpacity(0.8))
                              .make(),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 220,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredDocs.length,
                          itemBuilder: (BuildContext context, index) {
                            var doc = filteredDocs[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => DoctorProfile(doc: doc));
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: AppColors.whiteColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          height: 130,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primeryColor.withOpacity(0.8),
                                                AppColors.greenColor.withOpacity(0.8)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: doc['image'] == null || doc['image'] == ''
                                              ? Image.asset(
                                            AppAssets.imgLogin,
                                            fit: BoxFit.cover,
                                          )
                                              : Image.network(
                                            doc['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                AppAssets.imgLogin,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      10.heightBox,
                                      doc['docName']
                                          .toString()
                                          .text
                                          .size(AppFontSize.size16)
                                          .color(AppColors.primeryColor)
                                          .bold
                                          .align(TextAlign.center)
                                          .make(),
                                      5.heightBox,
                                      VxRating(
                                        onRatingUpdate: (value) {},
                                        maxRating: 5,
                                        count: 5,
                                        value: double.parse(doc['docRating']?.toString() ?? '0'),
                                        stepInt: true,
                                        selectionColor: AppColors.greenColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}