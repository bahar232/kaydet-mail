import 'package:flutter/material.dart';

/// Central color tokens for the "matte" black & white KAYDET theme,
/// plus the avatar/label palettes ported from the original design.
class AppColors {
  AppColors._();

  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color text = Colors.black;
  static const Color subText = Color(0xFF6B7280); // gray-500
  static const Color border = Color(0xFFE5E7EB); // gray-200
  static const Color inputBg = Color(0xFFF9FAFB); // gray-50
  static const Color hover = Color(0xFFF3F4F6); // gray-100
  static const Color accent = Colors.black;
  static const Color danger = Color(0xFFDC2626); // red-600

  /// Matte avatar background/foreground pairs, cycled by sender name.
  static const List<AvatarPalette> avatarPalettes = [
    AvatarPalette(Color(0xFFE2E8F0), Color(0xFF334155)), // slate
    AvatarPalette(Color(0xFFFEE2E2), Color(0xFF991B1B)), // red
    AvatarPalette(Color(0xFFFFEDD5), Color(0xFF9A3412)), // orange
    AvatarPalette(Color(0xFFFEF3C7), Color(0xFF92400E)), // amber
    AvatarPalette(Color(0xFFDCFCE7), Color(0xFF166534)), // green
    AvatarPalette(Color(0xFFD1FAE5), Color(0xFF065F46)), // emerald
    AvatarPalette(Color(0xFFCCFBF1), Color(0xFF115E59)), // teal
    AvatarPalette(Color(0xFFCFFAFE), Color(0xFF155E75)), // cyan
    AvatarPalette(Color(0xFFDBEAFE), Color(0xFF1E40AF)), // blue
    AvatarPalette(Color(0xFFE0E7FF), Color(0xFF3730A3)), // indigo
    AvatarPalette(Color(0xFFEDE9FE), Color(0xFF5B21B6)), // violet
    AvatarPalette(Color(0xFFF3E8FF), Color(0xFF6B21A8)), // purple
    AvatarPalette(Color(0xFFFAE8FF), Color(0xFF86198F)), // fuchsia
    AvatarPalette(Color(0xFFFCE7F3), Color(0xFF9D174D)), // pink
    AvatarPalette(Color(0xFFFFE4E6), Color(0xFF9F1239)), // rose
  ];

  static AvatarPalette avatarColorFor(String name) {
    if (name.isEmpty) return avatarPalettes.first;
    final index = name.codeUnitAt(0) % avatarPalettes.length;
    return avatarPalettes[index];
  }

  /// Selectable label colors, matching the original LABEL_COLORS list.
  static const List<LabelColorOption> labelColorOptions = [
    LabelColorOption('blue', 'Mavi', Color(0xFFDBEAFE), Color(0xFF1E40AF)),
    LabelColorOption('green', 'Yeşil', Color(0xFFDCFCE7), Color(0xFF166534)),
    LabelColorOption('red', 'Kırmızı', Color(0xFFFEE2E2), Color(0xFF991B1B)),
    LabelColorOption('yellow', 'Sarı', Color(0xFFFEF9C3), Color(0xFF854D0E)),
    LabelColorOption('purple', 'Mor', Color(0xFFF3E8FF), Color(0xFF6B21A8)),
    LabelColorOption('pink', 'Pembe', Color(0xFFFCE7F3), Color(0xFF9D174D)),
    LabelColorOption('gray', 'Gri', Color(0xFFE5E7EB), Color(0xFF1F2937)),
    LabelColorOption('indigo', 'İndigo', Color(0xFFE0E7FF), Color(0xFF3730A3)),
  ];
}

class AvatarPalette {
  final Color background;
  final Color foreground;
  const AvatarPalette(this.background, this.foreground);
}

class LabelColorOption {
  final String id;
  final String name;
  final Color background;
  final Color foreground;
  const LabelColorOption(this.id, this.name, this.background, this.foreground);
}
