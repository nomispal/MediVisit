import 'package:flutter/material.dart';

import '../../general/consts/colors.dart';

class CoustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? textcontroller;
  final Widget icon;
  final Color? textcolor;
  final String? Function(String?)? validator;

  const CoustomTextField({
    super.key,
    required this.hint,
    this.textcontroller,
    required this.icon,
    this.textcolor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textcontroller,
      style: TextStyle(
        fontSize: 16,
        color: textcolor ?? AppColors.textcolor,
      ),
      decoration: InputDecoration(
        prefixIcon: icon,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.secondaryTextColor.withOpacity(0.7),
        ),
        filled: true,
        fillColor: AppColors.whiteColor.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primeryColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primeryColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primeryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}