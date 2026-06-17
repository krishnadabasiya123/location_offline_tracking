import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

extension CustomAnimationExtension on Widget {
  /// 1. Fade Entrance Animation
  /// Usage: AnyWidget().customFadeIn(duration: 500)
  Widget customFadeIn({int delay = 0, int duration = 500}) {
    return _TweenAnimationWrapper(
      delay: delay,
      duration: duration,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: this,
    );
  }

  /// 2. Scale Entrance Animation
  /// Usage: AnyWidget().customScaleIn()
  Widget customScaleIn({int delay = 0, int duration = 500}) {
    return _TweenAnimationWrapper(
      delay: delay,
      duration: duration,
      tween: Tween<double>(begin: 0.5, end: 1),
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: this,
    );
  }

  /// 3. Slide Up Entrance Animation
  /// Usage: AnyWidget().customSlideInUp()
  Widget customSlideInUp({int delay = 0, int duration = 500, double distance = 30}) {
    return _TweenAnimationWrapper(
      delay: delay,
      duration: duration,
      tween: Tween<double>(begin: distance, end: 0),
      builder: (context, value, child) => Transform.translate(offset: Offset(0, value), child: child),
      child: this,
    );
  }

  /// 4. Tap/Press Scale Effect (Interaction)
  /// Makes the widget shrink slightly when pressed
  Widget customOnTapScale({VoidCallback? onTap, double scaleFactor = 0.95}) {
    return _CustomTapScaleWrapper(onTap: onTap, scaleFactor: scaleFactor, child: this);
  }

  /// 5. Shimmer Effect (Loading)
  /// Usage: MyWidget().customShimmer()
  Widget customShimmer({bool enabled = true, Color? baseColor, Color? highlightColor}) {
    if (!enabled) return this;
    return Shimmer.fromColors(baseColor: baseColor ?? Colors.grey[300]!, highlightColor: highlightColor ?? Colors.grey[100]!, child: this);
  }
}

// --- Internal Helper Wrappers ---

class _TweenAnimationWrapper extends StatelessWidget {
  const _TweenAnimationWrapper({required this.child, required this.tween, required this.builder, this.delay = 0, this.duration = 500});

  final Widget child;
  final Tween<double> tween;
  final Widget Function(BuildContext, double, Widget?) builder;
  final int delay;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: tween,
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOutBack,
      builder: builder,
      child: child,
    );
  }
}

class _CustomTapScaleWrapper extends StatefulWidget {
  const _CustomTapScaleWrapper({required this.child, this.onTap, this.scaleFactor = 0.95});

  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  @override
  State<_CustomTapScaleWrapper> createState() => _CustomTapScaleWrapperState();
}

class _CustomTapScaleWrapperState extends State<_CustomTapScaleWrapper> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = widget.scaleFactor),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100), child: widget.child),
    );
  }
}
// **************** example **************
// 1. Entrance Animation (Fade + Slide)
/*
CustomTextWidget("Welcome!")
    .customFadeIn(duration: 800)
    .customSlideInUp(distance: 50);
*/

// 2. Interactive Tap Effect (Scale)
/*
CustomImageWidget(
  imagePath: 'assets/images/product.png',
  width: 150,
).customOnTapScale(
  onTap: () => print("Image Clicked"),
  scaleFactor: 0.9, // Shrinks to 90% size when pressed
);
*/

// 3. Loading Shimmer Effect
/*
Container(
  width: double.infinity,
  height: 100,
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
).customShimmer(enabled: isDataLoading);
*/

// 4. Staggered List Item Animation
// (Items will appear one by one if you increase the delay)
/*
ListView.builder(
  itemBuilder: (context, index) {
    return MyListTile()
        .customFadeIn(delay: index * 100) // Each item fades in 100ms after the previous one
        .customSlideInUp(delay: index * 100);
  },
)
*/
// 5. Combined Profile Card with Animations and Dialog
/*
Column(
  children: [
    // A profile card that scales in, has a tap effect, and shows a dialog
    Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CustomImageWidget.circular(
            imagePath: 'https://i.pravatar.cc/150',
            size: 50,
          ),
          SizedBox(width: 15),
          const CustomTextWidget("John Doe", fontWeight: FontWeight.bold),
        ],
      ),
    )
    .customScaleIn(duration: 400) // Animation on entry
    .customOnTapScale(onTap: () { // Animation on click
       context.showCustomDialog(title: "Profile Clicked", message: "Viewing John's profile");
    }),
  ],
)
*/

// 6. Chaining multiple entrance animations
/*
CustomImageWidget(
  imagePath: 'assets/images/logo.png',
  width: 100,
)
.customFadeIn(duration: 800)
.customScaleIn()
.customSlideInUp(distance: 50); // Fades, scales, and slides up at once
*/

// 7. Adding a premium "Tap to Scale" effect to a card
/*
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(15)),
  child: CustomTextWidget("Clickable Card"),
).customOnTapScale(
  onTap: () => print("Card Tapped!"),
  scaleFactor: 0.92, // Shrinks slightly when pressed
);
*/

// 8. Shimmer loading state
/*
// Shows a gray shimmering box while data is loading
MyProductCard()
  .customShimmer(enabled: isLoading, baseColor: Colors.grey[300]);
*/
