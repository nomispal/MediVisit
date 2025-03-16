import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';

class AllReviewsScreen extends StatelessWidget {
  const AllReviewsScreen({super.key});

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.isEmpty) {
      return AssetImage(AppAssets.imgLogin); // Removed 'const' since AppAssets.imgLogin might not be a const expression
    }
    try {
      return NetworkImage(imageUrl);
    } catch (e) {
      return AssetImage(AppAssets.imgDoctor); // Removed 'const'
    }
  }

  Future<List<Map<String, dynamic>>> _getReviewsWithUserData() async {
    CollectionReference reviewsCollection = FirebaseFirestore.instance
        .collection('doctors')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('reviews');

    QuerySnapshot reviewsSnapshot = await reviewsCollection.get();
    List<Map<String, dynamic>> reviewsWithUserData = [];

    for (var reviewDoc in reviewsSnapshot.docs) {
      Map<String, dynamic> reviewData =
          reviewDoc.data() as Map<String, dynamic>? ?? {};
      String reviewBy = reviewData['reviewBy']?.toString() ?? '';

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(reviewBy)
          .get();
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>? ?? {};

      reviewsWithUserData.add({
        'review': {
          'comment': reviewData['comment']?.toString() ?? 'No comment',
          'rating': reviewData['rating']?.toString() ?? '0',
          'behavior': reviewData['behavior']?.toString() ?? 'Not rated',
          'reviewBy': reviewBy,
        },
        'user': {
          'fullname': userData['fullname']?.toString() ?? 'Unknown Reviewer',
          'image': userData['image']?.toString() ?? '',
        },
      });
    }
    return reviewsWithUserData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Reviews").text.make(),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getReviewsWithUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No reviews available"));
          }

          List<Map<String, dynamic>> reviews = snapshot.data!;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index]['review'];
              var user = reviews[index]['user'];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10.w),
                    leading: CircleAvatar(
                      backgroundImage: _getImageProvider(user['image']),
                      radius: 30.r,
                      backgroundColor: Colors.grey.shade200,
                      child: user['image'].isEmpty
                          ? Icon(
                        Icons.account_circle,
                        size: 40.r,
                        color: Colors.grey.shade600,
                      )
                          : null,
                    ),
                    title: Text(
                      "Reviewer: ${user['fullname']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    subtitle: Text(
                      review['comment'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18.w),
                        Text(
                          review['rating'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: _getImageProvider(user['image']),
                                  radius: 25.r,
                                  backgroundColor: Colors.grey.shade200,
                                  child: user['image'].isEmpty
                                      ? Icon(
                                    Icons.account_circle,
                                    size: 40.r,
                                    color: Colors.grey.shade600,
                                  )
                                      : null,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(user['fullname']),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Behavior: ${review['behavior']}"),
                                SizedBox(height: 8.h),
                                Text("Comment: ${review['comment']}"),
                                SizedBox(height: 8.h),
                                Text("Rating: ${review['rating']}"),
                                SizedBox(height: 8.h),
                                Text("Reviewed by: ${user['fullname']}"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Close").text.make(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}