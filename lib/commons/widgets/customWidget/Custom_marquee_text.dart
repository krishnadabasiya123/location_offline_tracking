import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class CustomMarqueeTextWithIcon extends StatelessWidget {
  const CustomMarqueeTextWithIcon({
    required this.text,
    required this.textStyle,
    super.key,
    this.width,
    this.imagePath, // Use for assets or network images
    this.iconData, // Use for Flutter Icons (e.g. Icons.star)
    this.iconSize = 18,
    this.spacing = 6,
    this.iconColor,
    this.textAlign = TextAlign.start,
    this.velocity = 30.0,
    this.blankSpace = 20.0,
    this.pauseAfterRound = const Duration(seconds: 2),
  });
  final String text;
  final TextStyle textStyle;
  final double? width;

  // New: Accept either Icon or Image
  final String? imagePath;
  final IconData? iconData;

  final double iconSize;
  final double spacing;
  final Color? iconColor;
  final TextAlign textAlign;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: width ?? double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          // Measure text width
          final textPainter = TextPainter(
            text: TextSpan(text: text, style: textStyle),
            textDirection: ui.TextDirection.ltr,
            maxLines: 1,
          )..layout();

          final textWidth = textPainter.size.width;

          // Calculate leading widget space
          final hasLeading = imagePath != null || iconData != null;
          final leadingSpace = hasLeading ? (iconSize + spacing) : 0.0;
          final totalNeeded = textWidth + leadingSpace;

          if (totalNeeded > maxWidth) {
            return _buildMarqueeRow(textPainter.size.height);
          } else {
            return _buildStaticRow();
          }
        },
      ),
    );
  }

  // Helper to build the leading Icon or Image
  Widget? _buildLeading() {
    if (imagePath != null) {
      return CustomImageWidget(
        imagePath: imagePath!,
        height: iconSize,
        width: iconSize,
        color: iconColor,
      );
    } else if (iconData != null) {
      return Icon(
        iconData,
        size: iconSize,
        color: iconColor ?? textStyle.color,
      );
    }
    return null;
  }

  Widget _buildMarqueeRow(double textHeight) {
    final leading = _buildLeading();
    return Row(
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(width: spacing),
        ],
        Expanded(
          child: SizedBox(
            height: textHeight + 4,
            child: Marquee(
              text: text,
              style: textStyle,
              blankSpace: blankSpace,
              velocity: velocity,
              pauseAfterRound: pauseAfterRound,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticRow() {
    final leading = _buildLeading();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: textAlign == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(width: spacing),
        ],
        Flexible(
          child: Text(
            text,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CustomMarqueeText extends StatelessWidget {
  const CustomMarqueeText({
    required this.text,
    required this.textStyle,
    super.key,
    this.width,
    this.textAlign = TextAlign.start,
    this.velocity = 30.0,
    this.blankSpace = 20.0,
    this.pauseAfterRound = const Duration(seconds: 2),
  });

  final String text;
  final TextStyle textStyle;
  final double? width;
  final TextAlign textAlign;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;

  // Helper method to convert TextAlign to MainAxisAlignment
  MainAxisAlignment _getAlignment() {
    switch (textAlign) {
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return MainAxisAlignment.end;
      case TextAlign.start:
      case TextAlign.left:
        return MainAxisAlignment.start;
      default:
        return MainAxisAlignment.start;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: width ?? double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          final textPainter = TextPainter(
            text: TextSpan(text: text, style: textStyle),
            textDirection: ui.TextDirection.ltr,
            maxLines: 1,
          )..layout();

          final textWidth = textPainter.size.width;

          final totalNeeded = textWidth;

          if (totalNeeded > maxWidth) {
            return _buildMarqueeRow(textPainter.size.height);
          } else {
            return _buildStaticRow();
          }
        },
      ),
    );
  }

  Widget _buildMarqueeRow(double textHeight) {
    return Row(
      mainAxisAlignment: _getAlignment(),
      children: [
        Expanded(
          child: SizedBox(
            height: textHeight + 4,
            child: Marquee(
              text: text,
              style: textStyle,
              blankSpace: blankSpace,
              velocity: velocity,
              pauseAfterRound: pauseAfterRound,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              // Note: Marquee package usually starts from the left
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticRow() {
    return Row(
      mainAxisAlignment: _getAlignment(),
      children: [
        Flexible(
          child: Text(
            text,
            style: textStyle,
            textAlign: textAlign, // Apply textAlign directly to Text widget as well
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
