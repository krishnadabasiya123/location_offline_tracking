import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomDashedBorder extends StatefulWidget {
  const CustomDashedBorder({
    required this.child,
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1.5,
    this.dashPattern = const <double>[6, 4],
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.all(2),
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.isAnimated = false,
    this.animationDuration = const Duration(seconds: 2),
  });

  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  /// If true, the dashes will move around the border (Marching Ants effect)
  final bool isAnimated;
  final Duration animationDuration;

  @override
  State<CustomDashedBorder> createState() => _CustomDashedBorderState();
}

class _CustomDashedBorderState extends State<CustomDashedBorder> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _controller = AnimationController(vsync: this, duration: widget.animationDuration)..repeat();
    }
  }

  @override
  void didUpdateWidget(CustomDashedBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && _controller == null) {
      _controller = AnimationController(vsync: this, duration: widget.animationDuration)..repeat();
    } else if (!widget.isAnimated && _controller != null) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: widget.borderRadius, boxShadow: widget.boxShadow),
      child: AnimatedBuilder(
        animation: _controller ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return CustomPaint(
            painter: _DashedBorderPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              borderRadius: widget.borderRadius,
              dashPattern: widget.dashPattern,
              backgroundColor: widget.backgroundColor,
              gradient: widget.gradient,
              phase: _controller?.value ?? 0,
            ),
            child: child,
          );
        },
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.strokeWidth, required this.dashPattern, required this.borderRadius, required this.phase, this.backgroundColor, this.gradient});

  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    // 1. Draw Background
    if (backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, backgroundPaint);
    }

    // 2. Prepare Border Paint
    final borderPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      borderPaint.shader = gradient!.createShader(rect);
    } else {
      borderPaint.color = color;
    }

    // 3. Draw Dashed Path
    final outerPath = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(outerPath, dashPattern, phase);
    canvas.drawPath(dashedPath, borderPaint);
  }

  Path _createDashedPath(Path originalPath, List<double> dashPattern, double phaseValue) {
    final dashedPath = Path();
    final pathMetrics = originalPath.computeMetrics();

    // Calculate the sum of pattern lengths to handle animation phase correctly
    final totalPatternLength = dashPattern.reduce((a, b) => a + b);

    for (final metric in pathMetrics) {
      // Start distance is shifted by the animation phase
      var distance = phaseValue * totalPatternLength;
      var dashIndex = 0;

      // We start behind the 0 point to ensure the path is full during animation
      while (distance > 0) {
        distance -= dashPattern[dashIndex % dashPattern.length];
        dashIndex++;
      }

      while (distance < metric.length) {
        final len = dashPattern[dashIndex % dashPattern.length];
        final double end = math.min(distance + len, metric.length);

        if (dashIndex.isEven && end > 0) {
          dashedPath.addPath(metric.extractPath(math.max(0, distance), end), Offset.zero);
        }
        distance = end;
        dashIndex++;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return true; // Repaint for animation
  }
}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
//       home: const DashedBorderShowcase(),
//     );
//   }
// }

// class DashedBorderShowcase extends StatelessWidget {
//   const DashedBorderShowcase({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // String for the "isToday" example
//     final todayDate = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

//     return Scaffold(
//       appBar: AppBar(title: const Text('Dashed Border Master Showcase'), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _section('1. Basic & Static', [
//               const CustomDashedBorder(
//                 color: Colors.blue,
//                 child: Padding(padding: EdgeInsets.all(10), child: Text('Simple Default')),
//               ),
//               const CustomDashedBorder(
//                 dashPattern: [2.0, 2.0], // Very tight dots
//                 strokeWidth: 2,
//                 child: Padding(padding: EdgeInsets.all(10), child: Text('Fine Dotted')),
//               ),
//             ]),

//             _section('2. Animated (Marching Ants)', [
//               const CustomDashedBorder(
//                 isAnimated: true,
//                 color: Colors.green,
//                 animationDuration: Duration(seconds: 1), // Fast
//                 child: Padding(padding: EdgeInsets.all(15), child: Text('Fast Animation')),
//               ),
//               const CustomDashedBorder(
//                 isAnimated: true,
//                 color: Colors.orange,
//                 animationDuration: Duration(seconds: 5), // Slow
//                 dashPattern: [20.0, 10.0],
//                 child: Padding(padding: EdgeInsets.all(15), child: Text('Slow & Long Dashes')),
//               ),
//             ]),

//             _section('3. Gradients & Neon', [
//               CustomDashedBorder(
//                 isAnimated: true,
//                 gradient: const LinearGradient(colors: [Colors.purple, Colors.pink, Colors.blue]),
//                 strokeWidth: 3,
//                 borderRadius: BorderRadius.circular(20),
//                 child: const Padding(padding: EdgeInsets.all(20), child: Text('Rainbow Border')),
//               ),
//               CustomDashedBorder(
//                 color: Colors.cyan,
//                 backgroundColor: Colors.black,
//                 boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha:0.5), blurRadius: 10)],
//                 child: const Padding(
//                   padding: EdgeInsets.all(15),
//                   child: Text('Neon Dark Mode', style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ]),

//             _section('4. Shapes & Avatars', [
//               CustomDashedBorder(
//                 isAnimated: true,
//                 borderRadius: BorderRadius.circular(100), // Perfect Circle
//                 color: Colors.red,
//                 strokeWidth: 3,
//                 padding: const EdgeInsets.all(4),
//                 child: const CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=1')),
//               ),
//               const Text('Active Story Style'),
//             ]),

//             _section('5. Practical UI Elements', [
//               // File Upload Style
//               CustomDashedBorder(
//                 color: Colors.grey,
//                 dashPattern: const [8.0, 4.0],
//                 backgroundColor: Colors.grey.withValues(alpha:0.05),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 30),
//                   child: const Column(
//                     children: [
//                       Icon(Icons.upload_file, color: Colors.grey),
//                       Text('Upload Documents', style: TextStyle(color: Colors.grey)),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // Coupon Style
//               CustomDashedBorder(
//                 color: Colors.redAccent,
//                 strokeWidth: 2,
//                 dashPattern: const [5.0, 5.0],
//                 borderRadius: BorderRadius.zero,
//                 backgroundColor: Colors.red.withValues(alpha:0.1),
//                 child: const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//                   child: Text('COUPON: SAVE50', style: TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ]),

//             _section('6. State Logic (Extension)', [
//               // This uses your isToday extension logic
//               CustomDashedBorder(
//                 isAnimated: todayDate.isToday,
//                 color: todayDate.isToday ? Colors.blue : Colors.grey,
//                 strokeWidth: todayDate.isToday ? 3.0 : 1.0,
//                 backgroundColor: todayDate.isToday ? Colors.blue.withValues(alpha:0.1) : Colors.transparent,
//                 child: Padding(padding: const EdgeInsets.all(15), child: Text(todayDate.isToday ? "Today's Task (Active)" : 'Past Task')),
//               ),
//               const SizedBox(height: 10),
//               // Error State
//               const CustomDashedBorder(
//                 color: Colors.red,
//                 dashPattern: [2.0, 2.0],
//                 child: Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Text('Invalid Input Field', style: TextStyle(color: Colors.red)),
//                 ),
//               ),
//             ]),

//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _section(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 15),
//           child: Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
//           ),
//         ),
//         Wrap(spacing: 20, runSpacing: 20, children: children),
//         const Divider(height: 40),
//       ],
//     );
//   }
// }

// // --- EXTENSION ---
// extension DateStringExtension on String {
//   bool get isToday {
//     try {
//       final parts = split('/');
//       final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
//       final now = DateTime.now();
//       return date.year == now.year && date.month == now.month && date.day == now.day;
//     } catch (_) {
//       return false;
//     }
//   }
// }
