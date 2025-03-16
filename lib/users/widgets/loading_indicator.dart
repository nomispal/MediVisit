import 'package:flutter/material.dart';
import 'package:hams/general/consts/consts.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color; // Added to allow custom colors

  const LoadingIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? AppColors.whiteColor, // Default to white
        strokeWidth: 3, // Slightly thicker for better visibility
        backgroundColor: AppColors.primeryColor.withOpacity(0.2), // Added subtle background
      ),
    );
  }
}