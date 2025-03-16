import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';

Widget buildReviewCard(QueryDocumentSnapshot review) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    color: AppColors.whiteColor,
    margin: const EdgeInsets.only(right: 10),
    child: Container(
      width: 150,
      height: 120,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Behavior: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primeryColor,
                    fontSize: AppFontSize.size14,
                  ),
                ),
                TextSpan(
                  text: review['behavior'],
                  style: TextStyle(
                    color: AppColors.textcolor,
                    fontSize: AppFontSize.size14,
                  ),
                ),
              ],
            ),
          ),
          5.heightBox,
          RichText(
            maxLines: 2,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Comment: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primeryColor,
                    fontSize: AppFontSize.size14,
                  ),
                ),
                TextSpan(
                  text: review['comment'].toString().length > 30
                      ? '${review['comment'].toString().substring(0, 30)}...'
                      : review['comment'],
                  style: TextStyle(
                    color: AppColors.textcolor,
                    fontSize: AppFontSize.size14,
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
          RatingBarIndicator(
            rating: review['rating'].toDouble(),
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20.0,
            direction: Axis.horizontal,
          ),
        ],
      ),
    ),
  );
}