
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class ErrorMessageOverlayContainer extends StatefulWidget {
  const ErrorMessageOverlayContainer({
    required this.errorMessage,
    required this.backgroundColor,
    super.key,
  });
  final String errorMessage;
  final Color backgroundColor;

  @override
  State<ErrorMessageOverlayContainer> createState() => _ErrorMessageOverlayContainerState();
}

class _ErrorMessageOverlayContainerState extends State<ErrorMessageOverlayContainer> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> slideAnimation;
  Timer? _timer; // 1. Create a timer variable

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    slideAnimation = Tween<double>(begin: -0.5, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOutCirc),
    );

    // 2. Assign the timer
    _timer = Timer(Duration(milliseconds: errorMessageDisplayDuration.inMilliseconds - 500), () {
      if (mounted) {
        animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 3. Cancel the timer here
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: slideAnimation,
      builder: (context, child) {
        return PositionedDirectional(
          start: MediaQuery.of(context).size.width * 0.05,
          bottom: MediaQuery.of(context).size.height * 0.075 * (slideAnimation.value),
          child: Opacity(
            opacity: slideAnimation.value < 0.0 ? 0.0 : slideAnimation.value,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: 8.sp(context), vertical: 8.sp(context)),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(10.sp(context)),
                ),
                child: Text(
                  widget.errorMessage.tr(context),
                  style: TextStyle(fontSize: 20.sp(context), color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
