import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // EdgeInsets
  static const EdgeInsetsGeometry paddingXs = EdgeInsets.all(xs);
  static const EdgeInsetsGeometry paddingSm = EdgeInsets.all(sm);
  static const EdgeInsetsGeometry paddingMd = EdgeInsets.all(md);
  static const EdgeInsetsGeometry paddingLg = EdgeInsets.all(lg);
  static const EdgeInsetsGeometry paddingXl = EdgeInsets.all(xl);

  // Gaps
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
}
