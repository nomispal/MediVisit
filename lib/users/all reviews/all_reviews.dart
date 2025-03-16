import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/all%20reviews/widget/review_grid_item.dart';
import 'package:velocity_x/velocity_x.dart';

class AllReviewsPage extends StatelessWidget {
  final String doctorId;

  const AllReviewsPage({Key? key, required this.doctorId}) : super(key: key);

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
                      child: "All Reviews"
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('doctors')
                      .doc(doctorId)
                      .collection('reviews')
                      .orderBy('rating', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.whiteColor,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: "No reviews available"
                            .text
                            .size(AppFontSize.size16)
                            .color(AppColors.whiteColor.withOpacity(0.8))
                            .make(),
                      );
                    }

                    var reviews = snapshot.data!.docs;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews[index];
                          return ReviewGridItem(review: review);
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
}