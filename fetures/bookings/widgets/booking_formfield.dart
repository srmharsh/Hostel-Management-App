import 'package:flutter/material.dart';
import 'package:hostel_management_app/utils/color_constants.dart';

class BookingTextField extends StatelessWidget {
  const BookingTextField(
      {super.key,
      required this.controller,
      this.suffix,
      this.enablde = true,
      required this.validator,
      this.onTap,
      this.readOnly = false});

  final TextEditingController controller;
  final Widget? suffix;
  final bool enablde;
  final Function(String?) validator;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final textField = SizedBox(
      height: 50,
      child: TextFormField(
        validator: (value) => validator(value),
        enabled: enablde,
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(width: 1.5, color: ColorConstants.primaryWhiteColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(width: 2, color: ColorConstants.primaryWhiteColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(width: 2, color: ColorConstants.primaryWhiteColor),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
    if (readOnly && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(child: textField),
      );
    }
    return textField;
  }
}
