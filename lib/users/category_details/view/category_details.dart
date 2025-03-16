import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../../general/consts/consts.dart';
import '../../doctor_profile/view/doctor_view.dart';
import '../../widgets/loading_indicator.dart';

class CategoryDetailsView extends StatelessWidget {
  final String catName;
  const CategoryDetailsView({super.key, required this.catName});

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
                      child: Text(
                        "$catName doctors",
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
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('doctors')
                      .where('docCategory', isEqualTo: catName)
                      .get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    var data = snapshot.data?.docs;

                    if (data == null || data.isEmpty) {
                      return Center(
                        child: Text(
                          'No doctor found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.whiteColor.withOpacity(0.8),
                          ),
                        ),
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
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, index) {
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => DoctorProfile(doc: data[index]));
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
                                        height: 120,
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
                                        child: data[index]['image'] == ''
                                            ? Image.asset(
                                          AppAssets.imgLogin,
                                          fit: BoxFit.cover,
                                        )
                                            : Image.network(
                                          data[index]['image'],
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
                                    const SizedBox(height: 10),
                                    Text(
                                      data[index]['docName'].toString(),
                                      style: TextStyle(
                                        fontSize: AppFontSize.size16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primeryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    RatingBarIndicator(
                                      rating: _parseRating(data[index]['docRating']),
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: AppColors.greenColor,
                                      ),
                                      itemCount: 5,
                                      itemSize: 20.0,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parseRating(dynamic rating) {
    try {
      if (rating == null) return 0.0;
      return double.parse(rating.toString());
    } catch (e) {
      return 0.0;
    }
  }
}