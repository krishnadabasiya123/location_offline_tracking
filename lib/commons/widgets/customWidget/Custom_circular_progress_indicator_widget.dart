import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key, this.color, this.strokeWidth, this.widthAndHeight});
  final Color? color;
  final double? strokeWidth;
  final double? widthAndHeight;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      height: widthAndHeight ?? 30,
      width: widthAndHeight ?? 30,
      child: Platform.isAndroid
          ? CircularProgressIndicator(color: color ?? context.primaryColor, backgroundColor: Colors.transparent, strokeWidth: 1.5)
          : CupertinoActivityIndicator(color: color ?? context.primaryColor),
    ),
  );
}
