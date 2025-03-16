import 'package:flutter/material.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';

class CoustomButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final LinearGradient? buttonColor; // Added to support gradient

  const CoustomButton({
    super.key,
    required this.onTap,
    required this.title,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero, // Remove default padding for gradient
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Matches SignupView
        ),
        elevation: 4, // Added elevation like SignupView's card
      ),
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: buttonColor ?? LinearGradient(
            colors: [AppColors.primeryColor, AppColors.greenColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: title.text
            .size(AppFontSize.size16)
            .color(AppColors.whiteColor)
            .bold
            .make(),
      ),
    );
  }
}