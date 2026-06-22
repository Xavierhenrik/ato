import 'package:flutter/material.dart';

extension LexContext on BuildContext {
  /// Padding inferior da safe area (usa [MediaQuery.viewPaddingOf] — ignora teclado).
  double get bottomPad => MediaQuery.viewPaddingOf(this).bottom;

  /// Padding superior da safe area.
  double get topPad => MediaQuery.viewPaddingOf(this).top;
}
