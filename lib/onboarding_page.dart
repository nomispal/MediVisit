import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingPage({super.key, required this.onGetStarted});

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Text
              Text(
                "Welcome to Hams",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // Doctor Image
              Image.asset(
                "assets/images/doctor.jpg",
                height: 200.h,
                width: 200.w,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 100,
                  ); // Fallback if the image fails to load
                },
              ),
              SizedBox(height: 30.h),

              // Quote
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  "“The good physician treats the disease; the great physician treats the patient who has the disease.”\n– William Osler",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.whiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 50.h),

              // Get Started Button
              ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whiteColor,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.primeryColor,
                    fontWeight: FontWeight.bold,
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