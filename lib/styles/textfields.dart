import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

Map<String, BoxDecoration> textfieldStyles = {
  "fullwidth_textfield": BoxDecoration(
    color: colorStyles['blue'],
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  ),
  "blue_textfield": BoxDecoration(
    color: Color(0xFF6CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  ),
  "white_textfield": BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 0.0,
        offset: Offset(0, 0),
      ),
    ],
  ),
  "white_textfield_bottom_border": BoxDecoration(
    color: Colors.white,
    border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1)),
  ),
  "white_textfield_sqaured": BoxDecoration(
    color: Colors.white.withOpacity(0.4),
    borderRadius: BorderRadius.circular(0.0),
  ),
};

Map<String, InputDecoration> textfieldInputDecoration(
        {IconData? iconData,
        String? hintText,
        String? hintTextStyle,
        String? suffixText}) =>
    {
      "white_text_decoration": InputDecoration(
        counterText: '',
        errorStyle: TextStyle(),
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(top: 14.0),
        prefixIcon: Icon(
          iconData,
          color: Colors.white,
          size: double.parse('30'),
        ),
        hintText: hintText,
        hintStyle: textStyles[hintTextStyle!],
        suffixText: suffixText,
      ),
      "black_text_decoration": InputDecoration(
        counterText: '',
        errorStyle: TextStyle(),
        border: InputBorder.none,
        // contentPadding: iconData == null
        // ? EdgeInsets.only(top: 0.0, left: 7)
        // : EdgeInsets.only(top: 10.0),
        prefixIcon: iconData == null
            ? null
            : Icon(
                iconData,
                color: Colors.grey.shade700,
                size: double.parse('25'),
              ),
        hintText: hintText,
        hintStyle: textStyles[hintTextStyle],
        suffixText: suffixText,
      ),
      "black_text_decoration_with_padding": InputDecoration(
        counterText: '',
        errorStyle: TextStyle(),
        border: InputBorder.none,
        contentPadding: iconData == null
            ? EdgeInsets.only(top: 0.0, left: 7)
            : EdgeInsets.only(top: 10.0),
        prefixIcon: iconData == null
            ? null
            : Icon(
                iconData,
                color: Colors.grey.shade700,
                size: double.parse('25'),
              ),
        hintText: hintText,
        hintStyle: textStyles[hintTextStyle],
        suffixText: suffixText,
      ),
    };
