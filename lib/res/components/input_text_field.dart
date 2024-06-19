import 'package:flutter/material.dart';
import 'package:tech_media/res/color.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({super.key,
  required this.myController,
    required this.focusNode,
    required this.onFieldSubmittedValue,
    required this.keyBoardType,
    required this.onValidator,
    required this.hint,
    this.autoFocus = false,
    this.enable = true,
    this.prefixIcon,
    required this.obscureText,
  });

  final TextEditingController myController;
  final FocusNode focusNode;
  final FormFieldSetter onFieldSubmittedValue;
  final FormFieldValidator onValidator;
  final Icon? prefixIcon;

  final TextInputType keyBoardType;
  final String hint;
  final bool obscureText;
  final bool enable, autoFocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        showCursor: true,
        cursorColor: Colors.red,
        controller: myController,
        focusNode: focusNode,
        validator: onValidator,
        onFieldSubmitted: onFieldSubmittedValue,
        keyboardType: keyBoardType,
        obscureText: obscureText,
        style: Theme.of(context).textTheme.bodyText2!.copyWith(height: 0, fontSize: 18),
        decoration: InputDecoration(

          prefixIcon: prefixIcon,
          hintText: hint,
          contentPadding: EdgeInsets.all(20),
          hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(height: 0, color: AppColors.primaryTextTextColor.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textFieldDefaultFocus)
          ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.secondaryColor)
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.alertColor)
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.textFieldDefaultBorderColor)
            )
        ),
      ),
    );
  }
}
