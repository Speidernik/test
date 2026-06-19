import 'package:flutter/material.dart';

const double kTabletBreakpoint = 768.0;

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= kTabletBreakpoint;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) =>
      isTablet(context) ? tablet : mobile;
}
