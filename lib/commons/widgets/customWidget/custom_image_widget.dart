import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    required this.imagePath,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.useShimmer = true,
    this.border,
    this.boxShadow,
    this.onTap,
    this.heroTag,
    this.opacity = 1.0,
  });

  /// Shortcut for a circular image
  const CustomImageWidget.circular({
    required this.imagePath,
    required double size,
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.useShimmer = true,
    this.border,
    this.boxShadow,
    this.onTap,
    this.heroTag,
    this.opacity = 1.0,
  }) : width = size,
       height = size,
       borderRadius = size;

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final double? borderRadius;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useShimmer;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final String? heroTag;
  final double opacity;

  // Performance optimization
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    // Determine source type
    final isNetwork = imagePath.startsWith('http');
    final isSvg = imagePath.toLowerCase().endsWith('.svg');
    final isFile = imagePath.startsWith('/') || imagePath.contains('users/'); // Basic check for local file paths

    // 1. Shimmer Placeholder
    final loadingWidget =
        placeholder ??
        (useShimmer
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: width, height: height, color: Colors.white),
              )
            : const Center(child: CircularProgressIndicator()));

    // 2. Error Widget
    final failureWidget =
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const CustomImageWidget(
            imagePath: AppImage.icIconHome,
            fit: BoxFit.contain,
            borderRadius: 10,
            opacity: 0.5,
          ),
        );

    // 3. Build Core Image logic
    var imageContent = switch ((isNetwork, isSvg, isFile)) {
      // Network SVG
      (true, true, _) => SvgPicture.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (_) => loadingWidget,
      ),
      // Network Raster
      (true, false, _) => CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        placeholder: (_, _) => loadingWidget,
        errorWidget: (_, _, _) => failureWidget,
      ),
      // Local File (from Gallery/Camera)
      (_, _, true) => Image.file(File(imagePath), width: width, height: height, fit: fit, alignment: alignment, color: color, errorBuilder: (_, _, _) => failureWidget),
      // Asset SVG
      (false, true, false) => SvgPicture.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (_) => loadingWidget,
      ),
      // Asset Raster
      (false, false, false) => Image.asset(imagePath, width: width, height: height, fit: fit, alignment: alignment, color: color, errorBuilder: (_, _, _) => failureWidget),
    };

    // 4. Wrap with Hero for transitions
    if (heroTag != null) {
      imageContent = Hero( tag: heroTag!, child: imageContent);
    }

    // 5. Build final decorated container
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(border: border, boxShadow: boxShadow, borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null),
          child: ClipRRect(borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : BorderRadius.zero, child: imageContent),
        ),
      ),
    );
  }
}
// **************** example **************
// 1. Basic Network Image with Rounded Corners
/*
CustomImageWidget(
  imagePath: 'https://example.com/banner.jpg',
  width: double.infinity,
  height: 200,
  borderRadius: 20,
)
*/

// 2. Circular Profile Picture with Border and Shadow
/*
CustomImageWidget.circular(
  imagePath: 'https://avatar.iran.liara.run/public/3',
  size: 80,
  border: Border.all(color: Colors.blue, width: 2),
  boxShadow: [
    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
  ],
)
*/

// 3. Local Asset SVG Icon with Color Filter
/*
CustomImageWidget(
  imagePath: 'assets/icons/home.svg',
  width: 24,
  height: 24,
  color: Colors.red,
)
*/

// 4. Local File Image (from Camera/Gallery)
/*
CustomImageWidget(
  imagePath: pickedFile.path, 
  width: 100,
  height: 100,
  borderRadius: 10,
)
*/
// 5. Network Image with Hero Animation and Tap Callback
/*  
CustomImageWidget(
  imagePath: 'https://example.com/photo.jpg',
  width: 150,
  height: 150,
  heroTag: 'photoHero',
  onTap: () {
    // Handle tap event
  },
)
*/

// 6. Network Image with Placeholder and Error Widget
/*
CustomImageWidget(
  imagePath: 'https://example.com/photo.jpg',
  width: 150,
  height: 150,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
*/

// 7. Network Image with Cached Network Image Provider
/*
CustomImageWidget(
  imagePath: 'https://example.com/photo.jpg',
  width: 150,
  height: 150,
  cacheWidth: 150,
  cacheHeight: 150,
)
*/
