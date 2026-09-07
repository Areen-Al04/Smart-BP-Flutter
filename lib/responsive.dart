import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const Responsive({super.key, required this.mobile, required this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return desktop;
        }
        return mobile;
      },
    );
  }
}

/// مساعد مركزي لحسابات الـ Responsive في كل الشاشات
class AppResponsive {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final bool isMobile;
  late final bool isTablet;
  late final bool isDesktop;

  AppResponsive(this.context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 900;
    isDesktop = screenWidth >= 900;
  }

  EdgeInsets get pagePadding {
    if (isMobile) return const EdgeInsets.all(16);
    if (isTablet) return const EdgeInsets.all(28);
    return const EdgeInsets.all(50);
  }

  double get titleFontSize {
    if (isMobile) return 22;
    if (isTablet) return 28;
    return 36;
  }

  double get subtitleFontSize {
    if (isMobile) return 18;
    if (isTablet) return 22;
    return 28;
  }

  double get bodyFontSize {
    if (isMobile) return 13;
    return 15;
  }

  double get iconSize {
    if (isMobile) return 22;
    return 30;
  }

  double get logoSize {
    if (isMobile) return screenWidth * 0.55;
    if (isTablet) return screenWidth * 0.40;
    return 380.0;
  }

  double get cardMaxWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return screenWidth * 0.85;
    return 900;
  }

  EdgeInsets get cardPadding {
    if (isMobile) return const EdgeInsets.all(20);
    if (isTablet) return const EdgeInsets.all(35);
    return const EdgeInsets.all(50);
  }

  bool get showFixedSidebar => isDesktop;
}
