import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool? readOnly;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color hintTextColor;
  final IconData? iconData;
  final IconData? suffixIcon;
  final bool? obscureText;
  final double? width;
  final double? height;
  final int? maxLine;

  const InputTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.keyboardType,
      this.readOnly = false,
       this.onTap,
      required this.backgroundColor,
      required this.hintTextColor,
      this.iconData,
      this.suffixIcon,
      this.obscureText = false,
      this.width,
      this.height = 50,
      this.maxLine = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width!,
      height: height,
      child: TextFormField(
        controller: controller,
        maxLines: maxLine,
       
        onTap: onTap,
        decoration: InputDecoration(
            labelText: hintText,
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(
              iconData,
            ),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            labelStyle: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
