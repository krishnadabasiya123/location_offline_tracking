import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.height,
    this.fontStyle,
    this.decoration,
  });

  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? height;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height, fontStyle: fontStyle, decoration: decoration),
    );
  }
}
// **************** example **************
// 1. Bold Header Text
/*
CustomTextWidget(
  "Product Details",
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
)
*/

// 2. Multiline Body Text with Line Height
/*
CustomTextWidget(
  "This is a long description about the product that might wrap into multiple lines.",
  fontSize: 14,
  maxLines: 3,
  height: 1.5,
  color: Colors.grey[700],
)
*/

// 3. Struck-through Price (Decoration)
/*
CustomTextWidget(
  "$100.00",
  fontSize: 12,
  decoration: TextDecoration.lineThrough,
  color: Colors.red,
)
*/
// 4. Center-aligned Text
/*  
CustomTextWidget(
  "This is a center-aligned text.",
  textAlign: TextAlign.center,
)
*/
// 5. Italic Subtitle
/*  
CustomTextWidget(
  "This is an italic subtitle.",
  fontSize: 12,
  fontStyle: FontStyle.italic,
)
*/
