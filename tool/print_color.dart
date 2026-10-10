import 'package:material_color_utilities/material_color_utilities.dart';

void main() {
  final scheme = SchemeTonalSpot(
    sourceColorHct: Hct.fromInt(0xFFFF9800),
    isDark: false,
    contrastLevel: 0.0,
  );
  final argb = MaterialDynamicColors.inversePrimary.getArgb(scheme);
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  print('inversePrimary ARGB: 0x${argb.toRadixString(16).padLeft(8, '0')}');
  print('RGB: ($r, $g, $b)');
}
