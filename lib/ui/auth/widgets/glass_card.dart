import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B31),
                borderRadius:
                    borderRadius ??
                    BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.white10),
              ),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
