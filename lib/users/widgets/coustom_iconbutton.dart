import 'package:flutter/material.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';

class CoustomIconButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final Color? color; // Kept for single-color option
  final Widget icon;
  final LinearGradient? buttonColor; // Added to support gradient

  const CoustomIconButton({
    Key? key,
    required this.onTap,
    required this.title,
    this.color,
    required this.icon,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 4,
      ),
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: buttonColor ??
              (color != null
                  ? null
                  : LinearGradient(
                colors: [AppColors.primeryColor, AppColors.greenColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
          color: color, // Fallback to solid color if provided
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            title.text
                .size(AppFontSize.size16)
                .color(AppColors.whiteColor)
                .bold
                .make(),
          ],
        ),
      ),
    );
  }
}